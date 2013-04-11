class User < ActiveRecord::Base
   attr_accessible :username , :password , :latitude , :longitude
   has_secure_password
end
