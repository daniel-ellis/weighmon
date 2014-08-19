require 'mongoid'

include Mongo
class Weight
  include Mongoid::Document
  field :user, type: String
  field :date, type: DateTime
  field :weight, type: Float
end

class User
  include Mongoid::Document
  field :user, type: String
  field :full_name, type: String
  field :height, type: Float
  field :color, type: String
end