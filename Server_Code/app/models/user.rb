class User < ActiveRecord::Base
   has_one :api_key
   attr_accessible :username , :password , :latitude , :longitude , :email , :message
   has_secure_password
   
end
