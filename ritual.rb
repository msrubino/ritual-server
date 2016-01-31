require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
Dir["./models/*.rb"].each {|file| require file }

# helper functions --------------------------------------------------
helpers do
  def getRandomName
    name = ""
    syllables = ["do", "re", "mi", "fa", "so", "la", "ti"]
    count = 2 + rand(4)
    for i in 0..count
      name += syllables.sample 
    end
    return name
  end

  def getRandomUUID
    name = rand(99999999)
  end
end

# utility functions
def getCurrentGame
  firstGame = RitualGame.first
  # if there's no game, need to create the game.
  if firstGame.nil? then firstGame = RitualGame.create( last_leader_at_ritual_number: 0 ) end

  return firstGame
end

def getCurrentRitualOrNil
  
  lastRitual = Ritual.last

  #if there's no ritual, none have been started yet
  if lastRitual.nil? || lastRitual.hasExpired? 
    puts "Nope"
    return nil
  end

  return lastRitual
end

def getPlayerByUUID( idToCheck )
  return RitualPlayer.find_by( uuid: idToCheck )
end

get '/' do
  # Show current list of users.
  "Ritual"
  RitualGame.all.to_json
end

# Admin routes --------------------------------------------------
get '/director' do
  @game       = getCurrentGame()
  @players    = @game.ritual_players
  @leader     = @game.hasLeader? ? @game.leader : nil
  @leadername = !@leader.nil? ? @leader.name : "There is no leader."

  erb :director 
end

get '/reset' do
  #Ritual.delete_all
  #RitualPlayer.delete_all
  RitualGame.destroy_all
  return "Butts."
end

# Player routes --------------------------------------------------
post '/join' do
  currentGame = getCurrentGame()

  numPlayers = currentGame.ritual_players.count

  # does the player already exist?
  player = RitualPlayer.find_by( uuid: params[:uuid] )
  if player.nil?
    # if not, create player.
    player = RitualPlayer.create( uuid: params[:uuid], name: params[:name], ritual_game: currentGame )

    if numPlayers == 1
      currentGame.setLeaderLapseTimeNow
    end
  end

  # assign player as leader if no leader assigned
  if currentGame.leader.nil?
    currentGame.newLeader
  end

  currentGame.save!

  resp = {}
  resp[:leader] = currentGame.leader
  resp[:ritual] = currentGame.rituals.last
  resp[:player] = player

  resp.to_json
end

post '/leave' do

  # is this a valid leaving player?
  leavingPlayer = RitualPlayer.find_by( uuid: params[:uuid] )
  if leavingPlayer.nil? then return puts "This player does not exist." end
  
  # if yes, go ahead and get rid of them.
  RitualPlayer.destroy_all(uuid: params[:uuid])

  # if there are no longer any players remaining
  currentPlayerCount = RitualGame.first.ritual_players.length.to_s()

  currentGame.exportJSON()
end

# Game routes --------------------------------------------------
post '/claim_leadership' do
  
  currentGame = getCurrentGame()

  # if a leader has already been assigned, return.
  if currentGame.hasLeader?
    puts "There is already a leader."
  else 
    claimer = getPlayerByUUID( params[:uuid] )
    # if the claimer is valid, set as new leader.
    if !claimer.nil? then currentGame.leader = claimer end
  end

  currentGame.exportJSON()
end

post '/declare_ritual' do

  currentGame = getCurrentGame()

  # validate leader
  uuid = params[:uuid]
  if uuid != currentGame.leader.uuid 
    return "You are not the leader."
  end

  # create a new ritual.
  type      = params[:ritual_type]
  duration  = Integer(params[:duration])
  starts_at = Time.current + (Integer(params[:starts_in])).seconds

  # set the leader's lapse time for the next ritual
  currentGame.setLeaderLapseTime( starts_at + duration.seconds + currentGame.lapseSeconds )

  # create ritual
  newRitual = Ritual.create( ritual_leader: currentGame.leader, ritual_type: type, duration: duration, starts_at: starts_at )

  # add the players from the current game to the ritual, and add the ritual to the current game's rituals.
  newRitual.ritual_players = currentGame.ritual_players
  currentGame.rituals << newRitual
  currentGame.save!
end

post '/performed_ritual' do
  performer = getPlayerByUUID( params[:uuid] )
  ritual = getCurrentRitualOrNil()
  if ritual.nil? then return "oops" end

  ritualStartTime = ritual.starts_at

  # check if player is in the current ritual
  if !ritual.ritual_players.include? performer then return "oops" end

  # if okay, player creates a ritual response and adds it to the ritual
  responseTime = Time.current - ritualStartTime;
  response = RitualResponse.create( ritual_player: performer, response_time: responseTime )
  
  ritual.ritual_responses << response
  ritual.save!
end

get '/ritual_results' do
  currentGame = getCurrentGame()
  currentGame.updateLeader

  first_response = currentGame.rituals.last.ritual_responses.first

  winner = unless first_response.nil? then first_response.ritual_player else "" end
  leader = currentGame.leader

  resp = {}
  resp[:winner] = winner
  resp[:leader] = leader

  resp.to_json
end

get '/current_ritual' do
  currentGame = getCurrentGame()
  lastRitual = currentGame.rituals.last

  lapseBegin = currentGame.leader_lapse_time - currentGame.lapseSeconds
  lapseEnd = currentGame.leader_lapse_time

  if lastRitual.nil?
    if Time.current > lapseEnd
      currentGame.newLeader
      currentGame.save
    end

    resp = {}
    resp[:leader] = currentGame.leader
    return resp.to_json
  end

  if !lastRitual.hasExpired?
    currentRitual = lastRitual
  end

  if Time.current > lapseEnd and lastRitual.created_at < lapseBegin
    currentGame.newLeader
    currentGame.save!
  end

  resp = {}
  resp[:leader] = currentGame.leader
  if !currentRitual.nil?
    resp[:ritual] = {}
    currentRitual.attributes.each do |k, v|
      resp[:ritual][k] = v
    end

    resp[:ritual][:time_until_start] = (currentRitual.starts_at - Time.current).seconds
  end

  resp.to_json
  #currentRitual.as_json( :include => [ :ritualType, :duration, :starts_at ] )

end
