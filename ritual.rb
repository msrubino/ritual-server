require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'

class Player < ActiveRecord::Base
end

get '/' do
  # Show current list of users.

  "Ritual"
  Player.all
end

# Player routes
get '/join/:id' do
  puts params[:id] + ' joined'
  @player = Player.new()
  @player.save
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
