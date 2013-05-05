class MomentsController < ApplicationController
  #note: controller deprecated - was easier and faster to send and receive moments directly from S3
  before_filter :restrict_access #before any action, ensure the user has access
  #edits a users metadata regarding current location
  def edit
    @user = current_user 
    if(@user)
      @user.latitude = params[:latitude]
      @user.longitude = params[:longitude]
      @user.message = params[:message]
      @user.save
      render json: {latitude: @user.latitude, longitude: @user.longitude, message: @user.message}
    else
      render json: {error: 'No User Found'}
    end
  end
  #destroys a users current access
  def destroy
    session[:user_id]=nil
    render json: {logged_out: true}
    #redirect_to root_path, :notice => 'Logged out.'
  end
end
