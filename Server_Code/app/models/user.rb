class User < ActiveRecord::Base
   #allows user to have many friendships of any type
   has_many :friendships
   has_many :confirmed_friendships
   has_many :pending_friendships
   has_many :friends, :through => :confirmed_friendships #friendships are only through confirmed friends
   has_one :api_key #each user has one api key
   attr_accessible :username , :password , :latitude , :longitude , :email , :message , :name #attributes for a user
   has_secure_password #ensures secure password
   validates_uniqueness_of :username, :email #ensures no duplicate email addresses or usernames
   
end
