require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/ritual_player'


get '/' do
  # Show current list of users.

  "Ritual"
  RitualPlayer.all.to_json
end

# Player routes
get '/join/:id' do
  puts params[:id] + ' joined'
  @player = RitualPlayer.create(uuid: "Hello", name: "HelloTwo")

end

get '/leave/:id' do
  puts params[:id] + ' left'
end

# Game routes
post '/declare_ritual' do
end

post '/perform_ritual' do
end

post '/declare_leader' do
end

post '/claimleadership' do
end

get '/sync' do
end
