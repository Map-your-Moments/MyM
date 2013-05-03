class UsersController < ApplicationController
  before_filter :restrict_access, :only => [:update, :destroy]
  # GET /users
  # GET /users.json
  
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
  def show
    user = User.find_by_username(params[:username])

    respond_to do |format|
      format.html #show.html.erb
      format.json { render json: { email: user.email }}
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    #@user = current_user
    @user = User.find(params[:id])

    #respond_to do |format|
    #  format.json {render json: @user }
    #end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    #respond_to do |format|
      if @user.save
        @user.create_api_key
        UserMailer.welcome(@user).deliver
        #format.html { redirect_to @user, notice: 'User was successfully created.' }
        render json: {created: true, access_token: @user.api_key.access_token}
      else
        #format.html { render action: "new" }
        render json: {created: false}
      end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = current_user
    #@user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        #format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render json: {:updated => 'true' } }
      else
        #format.html { render action: "edit" }
        format.json { render json: {:updated => 'false' } }
        #format.json { render json: @user.errors, type: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    #@user = User.find(params[:id])
    @user = current_user
    @user.destroy

    #respond_to do |format|
      render json: {:deleted => ' true' }
  end  
end
