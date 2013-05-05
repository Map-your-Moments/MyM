class UsersController < ApplicationController
  before_filter :restrict_access, :only => [:update, :destroy] #ensures that user is authenticated for specific methods
  # GET /users
  # GET /users.json
  #returns list of all users - only username, email, and name 
  def index
    @users = User.find(:all, :select => 'username, email, name')
    #@users = User.all

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  # returns a requested user's email
  def show
    user = User.find_by_username(params[:username]) #finds user by username

    respond_to do |format| #returns users email
      format.html #show.html.erb
      format.json { render json: { email: user.email }}
    end
  end

  # GET /users/new
  # GET /users/new.json
  # begins creation of new user
  def new
    @user = User.new #begins creation of new user

    respond_to do |format| #returns created user information
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  # allows for user to be edited
  def edit
    #@user = current_user
    @user = User.find(params[:id])

    #respond_to do |format|
    #  format.json {render json: @user }
    #end
  end

  # POST /users
  # POST /users.json
  # finalizes creation of new user
  def create
    @user = User.new(params[:user]) #finds created user

    #respond_to do |format|
      if @user.save
        @user.create_api_key #generates api key for new user
        UserMailer.welcome(@user).deliver #sends welcome email to new user
        #format.html { redirect_to @user, notice: 'User was successfully created.' }
        render json: {created: true, access_token: @user.api_key.access_token} #returns that user was created successfully
      else
        #format.html { render action: "new" }
        render json: {created: false} #returns if user creation failed
      end
  end

  # PUT /users/1
  # PUT /users/1.json
  # allows for user to be updated
  def update
    @user = current_user #finds current user
    #@user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user]) #attempts to update user attributes
        #format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render json: {:updated => 'true' } } #returns if update successful
      else
        #format.html { render action: "edit" }
        format.json { render json: {:updated => 'false' } } #returns if update failed
        #format.json { render json: @user.errors, type: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # destroys the user
  def destroy
    #@user = User.find(params[:id])
    #finds and destroys the current user
    @user = current_user
    @user.destroy

    #respond_to do |format| #returns that deletion was true
      render json: {:deleted => ' true' }
  end  
end
