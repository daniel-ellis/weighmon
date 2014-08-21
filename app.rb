require 'sinatra'
require 'json'

require_relative 'mongo'
require_relative 'lib/weight_helper'
require_relative 'lib/user_helper'

include WeightHelper
include UserHelper

# require './lib/syslotem_info'

set :server, 'thin'

get '/' do
  @cards = [
    {title: 'Users', color: 'red', icon: 'fa-child'},
    {title: 'History', color: 'green', icon: 'fa-bar-chart-o'}
  ]
  erb :index
end

get '/history' do
  @data = history_last_week

  erb :history
end

get '/users' do
  @users = %w.roo dan.

  erb :users
end

get '/users/:name' do |name|
  u = user(name)

  weights = user_weights(name).desc(:date).to_a
  change = weights.last[:weight] - weights.first[:weight]

  week_weights = weights_for_between(name, Time.now - 7.days, Time.now).to_a
  week_change = week_weights.last[:weight] - week_weights.first[:weight]

  @user = {
    name: u[:full_name],
    slug: u[:user],
    weights: weights,
    change: change,
    week_change: week_change
  }

  erb :user
end

post '/weight/:name' do |name|
  body = request.body.rewind
  payload = JSON.parse request.body.read
  puts payload
  date = payload['date']
  weight = payload['mass']
  test = payload['test']

  user_create({
    user: name,
    date: date,
    weight: weight,
    test: test
  })

end

delete '/weight/:id' do |id|
  # Weight.where(_id: id).delete
  # 201
  puts "Tried to delete #{id}"
  201
end

get '/weight/all', :provides => 'application/json' do
  all_weights.to_json
end

get '/weight/all/from/:from/til/:til', :provides => 'application/json' do |from, til|
  # Weight.where(:date.gte => from, :date.lte => til).to_json
  weights_for_between(nil, from, til).to_json
end

get '/weight/all/from/:from', :provides => 'application/json' do |from|
  # Weight.where(:date.gte => from, :date.lte => Date.today).to_json
  weights_for_between(nil, from, Date.today).to_json
end

get '/weight/:name/all', :provides => 'application/json' do |name|
  user_weights(name).to_json
end

get '/weight/:name/from/:from/til/:til', :provides => 'application/json' do |name, from, til|
  # Weight.where(user: name,:date.gte => from, :date.lte => til).to_json
  weights_for_between(name, from, til).to_json
end

