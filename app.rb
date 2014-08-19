require 'sinatra'
require 'sinatra-websocket'
require 'json'

require_relative 'mongo'
require_relative 'lib/weight_helper'

include WeightHelper

# require './lib/syslotem_info'

set :server, 'thin'
set :clients, []

def kg_to_lbs(kg)
  (kg * 2.2046).round(2)
end

def time_ago_in_words(t)
  time = t.to_i
  seconds = Time.now.to_i - time
  minutes = seconds / 60
  hours = minutes / 60
  days = hours / 24
  years = days / 365
  descriptions = ['Today', 'Yesterday', '2 days ago', '3 days ago', '4 days ago', '5 days ago']
  if days < 6 && days >= 0
    return descriptions[days]
  end
  format = '%A %d %B'
  format += '\'%y' if years > 0 
  t.strftime(format)
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
  @data = last_7
   
  erb :history
end

get '/users' do
  @users = %w.roo dan.
  
  erb :users
end

# get '/create' do
#   User.create(
#   full_name: 'Dan Ellis',
#   user: 'dan',
#   height: 70,
#   color: 'blue'
#   )
# end


get '/users/:name' do |name|
  user = User.where(user: name).first

  weights = Weight.where(user: name).desc(:date).to_a
  change = weights.last[:weight] - weights.first[:weight]

  week_weights = weights_for_between(name, Time.now - 7.days, Time.now).to_a
  week_change = week_weights.last[:weight] - week_weights.first[:weight]

  @user = {
    name: user[:full_name],
    slug: user[:user],
    weights: weights,
    change: change,
    week_change: week_change
  }
  
  erb :user
end

def last_7
  data = []  
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
    data << user
  end
  data
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

delete '/weight/:id' do |id|
  # Weight.where(_id: id).delete
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