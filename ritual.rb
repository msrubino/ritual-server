require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
Dir["./models/*.rb"].each {|file| require file }

get '/' do
  # Show current list of users.

  "Ritual"
  RitualPlayer.all.to_json
end

# Player routes
get '/join' do
  begin
    RitualPlayer.create(uuid: params[:uuid], name: params[:name])
    puts "#{params[:uuid]} joined."
  rescue
    puts "Player #{params[:uuid]} already exists."
  end
end

get '/leave' do
  RitualPlayer.destroy_all(uuid: params[:uuid])
  puts "#{params[:id]} left."
end

# Game routes
post '/claimleadership' do
end

post '/declare_ritual' do
end

post '/perform_ritual' do
end

post '/declare_leader' do
end

get '/reset' do
    Ritual.destroy_all
    RitualPlayer.destroy_all
    RitualGame.destroy_all
    "All gone."
end

get '/sync' do
end
