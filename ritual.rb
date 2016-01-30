require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
Dir["./models/*.rb"].each {|file| require file }

# helper functions --------------------------------------------------
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

end

get '/reset' do
    Ritual.destroy_all
    RitualPlayer.destroy_all
    RitualGame.destroy_all
    "All gone."
end

# Player routes --------------------------------------------------
get '/join' do

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
  playerCount = currentGame.ritual_players.length.to_s() 
  leaderName = currentGame.leader.name 
  puts "There are currently #{playerCount} players. The leader is #{leaderName}."

  currentGame.exportJSON()
end

get '/leave' do

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
get '/claim_leadership' do
  
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

get '/declare_ritual' do

  currentGame = getCurrentGame()

  # create a new ritual.
  type      = params[:ritual_type]
  duration  = params[:duration] 
  starts_at = Time.now + Integer(params[:starts_in])

  newRitual = Ritual.create( ritual_type: type, duration: duration, starts_at: starts_at )

  # add the players from the current game to the ritual, and add the ritual to the current game's rituals.
  newRitual.ritual_players = currentGame.ritual_players
  currentGame.rituals << newRitual

  currentGame.exportJSON()
end

get '/perform_ritual/:UUID' do
  performer = getPlayerByUUID( params[:UUID] )
  ritual = getCurrentRitualOrNil()
  ritualStartTime = ritual.starts_at

  # TODO if the current ritual is nil for whatever reason, leave
  if ritual.nil? then return "oops" end

  # check if player is in the current ritual
  if !ritual.ritual_players.include? performer then return "oops" end

  # if okay, player creates a ritual response and adds it to the ritual
  responseTime = Time.now - ritualStartTime;
  response = RitualResponse.create( response_time: responseTime )
  
  ritual.ritual_responses << response

  currentGame.exportJSON()
end

get '/sync' do
  # PHASES
  # during declare ritual phase...searching for the next ritual.
  # during the ritual phase...nothing happening.
  # during the post ritual phase...searching for the next ritual (unless there's no leader)
end
