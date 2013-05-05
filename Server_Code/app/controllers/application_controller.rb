class ApplicationController < ActionController::Base
  protect_from_forgery
private                                      
   #locate the current user through the user_id
   def current_user
     @user||=User.find(session[:user_id])
   end
   #ensure the user has a correct access token
   def restrict_access
      access_key = ApiKey.find_by_access_token(params[:access_token])
      if(access_key)
        session[:user_id] = access_key.user.id
      end
   end    
end
