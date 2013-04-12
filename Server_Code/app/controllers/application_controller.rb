class ApplicationController < ActionController::Base
  protect_from_forgery
private                                      
   def current_user
     @user||=User.find(session[:user_id])
   end
   def restrict_access
      access_key = ApiKey.find_by_access_token(params[:access_token])
      if(access_key)
        session[:user_id] = access_key.user.id
      end
   end    
end
