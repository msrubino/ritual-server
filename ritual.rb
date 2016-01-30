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
  if firstGame.nil? then firstGame = RitualGame.create end

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

post '/reset' do
  Ritual.destroy_all
  RitualPlayer.destroy_all
  RitualGame.destroy_all
  
  redirect '/director'
end

# Player routes --------------------------------------------------
post '/join' do
  currentGame = getCurrentGame()

  # does the player already exist?
  player = RitualPlayer.find_by( uuid: params[:uuid] )
  if player.nil?
    # if not, create player.
    player = RitualPlayer.create( uuid: params[:uuid], name: params[:name], ritual_game: currentGame )
  end

  # assign player as leader if no leader assigned
  if currentGame.leader.nil?
    currentGame.leader = currentGame.ritual_players.sample()
  end

  #Debug
=begin
  playerCount = currentGame.ritual_players.length.to_s() 
  leaderName = currentGame.leader.name 
  puts "There are currently #{playerCount} players. The leader is #{leaderName}."
=end

  #currentGame.exportJSON()
  puts params[:uuid]

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
  duration  = params[:duration] 
  starts_at = Time.now + Integer(params[:starts_in])

  newRitual = Ritual.create( ritual_type: type, duration: duration, starts_at: starts_at )

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
  responseTime = Time.now - ritualStartTime;
  response = RitualResponse.create( ritual_player: performer, response_time: responseTime )
  
  ritual.ritual_responses << response
  ritual.save!
end

get '/ritual_results' do
  ritualGameId = params[:ritual_game_id]
  begin
    currentGame = RitualGame.find(ritualGameId)
  rescue
    return "No game found."
  end

  currentGame.updateLeader

  first_response = currentGame.rituals.last.ritual_responses.first

  winner = unless first_response.nil? then first_response.ritual_player else "" end
  leader = currentGame.leader

  resp = {}
  resp[:winner] = winner
  resp[:leader] = leader

  resp.to_json
end

get '/sync' do
  # PHASES
  # during declare ritual phase...searching for the next ritual.
  # during the ritual phase...nothing happening.
  # during the post ritual phase...searching for the next ritual (unless there's no leader)
end
