class MomentsController < ApplicationController
  def edit
    @user = User.find(session[:user_id])
    if(@user)
      @user.latitude = params[:latitude]
      @user.longitude = params[:longitude]
      @user.save
      render json: {latitude: @user.latitude, longitude: @user.longitude}
    else
      render json: {error: 'No User Found'}
    end
  end
  def destroy
    session[:user_id]=nil
    render json: {logged_out: true}
    #redirect_to root_path, :notice => 'Logged out.'
  end
end
