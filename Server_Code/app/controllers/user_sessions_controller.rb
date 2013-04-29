class UserSessionsController < ApplicationController
  
  # GET /user_sessions
  # GET /user_sessions.json
=begin
  def index
    @user_sessions = UserSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_sessions }
    end
  end
=end
=begin
  # GET /user_sessions/1
  # GET /user_sessions/1.json
  def show
    @user_session = UserSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_session }
    end
  end
=end
=begin
  # GET /user_sessions/new
  # GET /user_sessions/new.json
  def new
    @user_session = UserSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_session }
    end
  end
=end
=begin
  # GET /user_sessions/1/edit
  def edit
    @user_session = UserSession.find(params[:id])
  end
=end
  # POST /user_sessions
  # POST /user_sessions.json
  def create
    user = User.find_by_username(params[:username])

    if (user && user.authenticate(params[:password]))
        session[:user_id]=user.id
        render json: {logged_in: true, access_token: user.api_key.access_token}
    else 
        render json: {logged_in: false, access_token: nil}
    end
  end

=begin    
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.html { redirect_to @user_session, notice: 'User session was successfully created.' }
        format.json { render json: @user_session, status: :created, location: @user_session }
      else
        format.html { render action: "new" }
        format.json { render json: @user_session.errors, status: :unprocessable_entity }
      end
    end
  end
=end
=begin
  # PUT /user_sessions/1
  # PUT /user_sessions/1.json
  def update
    @user_session = UserSession.find(params[:id])

    respond_to do |format|
      if @user_session.update_attributes(params[:user_session])
        format.html { redirect_to @user_session, notice: 'User session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_session.errors, status: :unprocessable_entity }
      end
    end
  end
=end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.json
  def destroy
    render json: {logged_out: true}
  end

=begin    
    @user_session = UserSession.find(params[:id])
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to user_sessions_url }
      format.json { head :no_content }
    end
  end
=end 
=begin 
     private                                                                                                    
        
       def restrict_access
         authenticate_or_request_with_http_token do |token, options|
           ApiKey.exists?(access_token: token)
         end
    end
=end
end
