require 'sinatra'
require 'sinatra-websocket'
require 'json'

require_relative 'mongo'


# require './lib/syslotem_info'

set :server, 'thin'
set :clients, []

def kg_to_lbs(kg)
  kg * 2.2046
end

get '/' do
  
  @cards = [
    # {title: 'Weight', val: '181', color: 'red', icon: 'fa-qq'},
    {title: 'Users', val: '181', color: 'red', icon: 'fa-child'},
    {title: 'History', val: '181', color: 'green', icon: 'fa-bar-chart-o'},
    {title: 'Change', val: '181', color: 'purple', icon: 'fa-exchange'}
  ]
  erb :index
end

get '/history' do
  
  @data = []  
  %w.roo dan..each do |name|
    user = {
      name: name,
      dates: [],
      values: []
    }
    (Date.today - 7 ).upto(Date.today) do |date|
      user[:dates] << date.strftime
      weight = Weight.where(user: name,:date.gte => date, :date.lte => date).first
      val = weight ? kg_to_lbs(weight.weight) : nil
      user[:values] << val
    end
    @data << user
  end
   
  erb :history
end
# {"date"=>"2014-08-16 13:19:19 +0000", "mass"=>"82.88492"}
post '/weight/:name' do |name|
  body = request.body.rewind
  payload = JSON.parse request.body.read
  puts payload
  date = payload['date']
  weight = payload['mass']
  test = payload['test']
  Weight.create( 
        user: name,
        date: date,
        weight: weight,
        test: test
      )
end


get '/weight/all' do
  Weight.all.to_json
end

get '/weight/all/from/:from/til/:til' do |from, til|
  Weight.where(:date.gte => from, :date.lte => til).to_json
end

get '/weight/all/from/:from' do |from|
  Weight.where(:date.gte => from, :date.lte => Date.today).to_json
end

get '/weight/:name/all' do |name|
  Weight.where(user: name).to_json
end

get '/weight/:name/from/:from/til/:til' do |name, from, til|
  Weight.where(user: name,:date.gte => from, :date.lte => til).to_json
end

def someone_still_listening
  settings.clients.count > 0
end

Thread.new {
  while true do 
    puts 'Tick'
    update_info if someone_still_listening
    sleep 3
  end
}

def send_message (message)
  settings.clients.each do |client|
    client.send message
  end  
end