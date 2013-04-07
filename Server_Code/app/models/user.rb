class User < ActiveRecord::Base
   attr_accessible :password, :username
   has_secure_password
end
