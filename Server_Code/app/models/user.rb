class User < ActiveRecord::Base
   has_one :api_key
   attr_accessible :username , :password , :latitude , :longitude
   has_secure_password
   
end
