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
