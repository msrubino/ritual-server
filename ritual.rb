require 'sinatra'

get '/' do
  "Ritual"
  # Show current list of users.
end

# Player routes
get '/join/:id' do
  puts params[:id] + ' joined'
end

get '/leave/:id' do
  puts params[:id] + ' left'
end

# Game routes
get '/declare_ritual' do
end

get '/perform_ritual' do
end

get '/declare_leader' do
end

get '/sync' do
end
