require 'sinatra'
require '../lib/gothonweb/map.rb'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"
enable :sessions
set :session_secret, 'BADSECRET'

get '/' do
    redirect to('/login')
end


get '/login' do
  erb :login

end

post '/login' do
  # save session for user_name, user_score
  # redirect to /game
  session[:user_name]=params[:user_name]
  session[:user_score]=0
  puts "#{params}, #{session[:user_name]}"

  session[:room] = 'START'
  redirect to('/game')
end


get '/game' do
  room = Map::load_room(session)
  user_name=session[:user_name]
  user_score=session[:user_score]
  options = []

  if room
    puts "#{room}"
    if room.name == "Central Corridor"
      session[:user_score]+=0
       user_score=session[:user_score]
        options = ["shoot!", "dodge!", "tell-a-joke"]
    elsif room.name == "Laser Weapon Armory"
      session[:user_score]+=200
       user_score=session[:user_score]
       options = ["1234", "0123", "0980"]
     elsif room.name == "The Bridge"
       session[:user_score]+=300
        user_score=session[:user_score]
         options = ["slowly-place-the-bomb", "throw-the-bomb","sit-on-the-bomb"]
     elsif room.name == "Escape Pod"
       session[:user_score]+=500
        user_score=session[:user_score]
        options = ["1", "2", "3"]
     end

     erb :show_room, :locals => {room: room,name: user_name,score: user_score,answers: options}
  else
      erb :you_died, :locals => {room: room,name: user_name,score: user_score}
   end
end


post '/game' do
  room = Map::load_room(session)
  action = params[:options].gsub("-"," ")
  puts "#{params[:options]}"
  if room
      next_room = room.go(action) || room.go("*")

      if next_room
          Map::save_room(session, next_room)
      end

      redirect to('/game')
  else
      erb :you_died
  end
end
