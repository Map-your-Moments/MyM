class User < ActiveRecord::Base
   has_many :friendships
   has_many :confirmed_friendships
   has_many :pending_friendships
   has_many :friends, :through => :confirmed_friendships
   has_one :api_key
   attr_accessible :username , :password , :latitude , :longitude , :email , :message , :name
   has_secure_password
   validates_uniqueness_of :username, :email
   
end
