class User < ActiveRecord::Base
   has_many :friendships
   has_many :friends, :through => :friendships
   has_one :api_key
   attr_accessible :username , :password , :latitude , :longitude , :email , :message
   has_secure_password
   
end
