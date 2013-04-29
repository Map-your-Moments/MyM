class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    #@user = User.find(session[:user_id])
    @user = current_user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: User.all }
      #format.json { render json: {latitude:  @user.latitude, longitude: @user.longitude} }
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
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @user.create_api_key
        UserMailer.welcome(@user).deliver
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: {created: true, exists: false, access_token: @user.api_key.access_token}}
      else
        format.html { render action: "new" }
        format.json { render json: {created: false}}
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, type: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    #@user = User.find(params[:id])
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { render json: {deleted: true} }
    end
  end
end
