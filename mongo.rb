require 'mongoid'

include Mongo
class Weight
  include Mongoid::Document
  field :user, type: String
  field :date, type: Date
  field :weight, type: Float
end