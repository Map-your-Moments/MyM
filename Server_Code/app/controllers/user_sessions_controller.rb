class UserSessionsController < ApplicationController
  #creates a session for the user upon login
  def create
    user = User.find_by_username(params[:username])
    #ensures that the user has access and exists
    if (user && user.authenticate(params[:password]))
        session[:user_id]=user.id
        render json: {logged_in: true, email: user.email, name: user.name, access_token: user.api_key.access_token}
    else 
        render json: {logged_in: false, access_token: nil}
    end
  end
  #logs out a user
  def destroy
    render json: {logged_out: true}
  end
end
