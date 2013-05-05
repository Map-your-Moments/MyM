class FriendshipsController < ApplicationController
  before_filter :restrict_access #checks that user has approproate access
  # GET /friendships
  # GET /friendships.json
  # returns all friendships
  def index
    @friendships = Friendship.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @friendships }
    end
  end

  # GET /friendships/1
  # GET /friendships/1.json
  # returns the user's current friends
  def show
    @user=current_user #gets current user
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user.friends } #returns all the friends of the user
    end
  end

  # GET /friendships/new
  # GET /friendships/new.json
  # begins creation of friendship
  def new
    #finds user and friend
    @user=current_user
    friend=User.find_by_email(params[:email])

    if(friend) #ensures that friend exists
      friendCheck=Friendship.find_by_user_id_and_friend_id(@user.id, friend.id) #checks if friendship already exists
      if(!friendCheck)
        #creates friendship and defaults to Pending
        @friendship = @user.friendships.build(:friend_id => friend.id)

        respond_to do |format|
          if @friendship.save
            @friendship=friend.friendships.build(:friend_id => @user.id) #creates friendship and defaults to Pending
            if @friendship.save
              UserMailer.confirmation(@user,friend).deliver #sends email if created successfully
              #returns created friendship status
              format.html { redirect_to @friendship, notice: 'Friendship was successfully created.' }
              format.json { render json: {:created => 'true', :exists => 'true', :friends => 'false'}}
            else
              format.html { render action: "new" }
              format.json { render json: {:created => 'false', :exists => 'true', :friends => 'false'}}
            end
          else
            render json: {:created => 'false', :exists => 'true', :friends => 'false'}
          end
        end
      else
        #friendship already existed
        render json: {:created => 'false', :exists => 'true', :friends => 'true'}
      end
    else
      #friend does not exist
      render json: {:created => 'false', :exists => 'false',  :friends => 'false'}
    end
  end

  # GET /friendships/1/edit
  # allows for editing of a friendship
  def edit
    @friendship = Friendship.find(params[:id])
  end
  
  #creates the friendship, allows for change to Confirmed when confirmation link chosen
  def create
    #finds the user and friend
    @user=User.find(params[:uid])
    friend=User.find(params[:fid])
    #checks that the friend and user exist
    if(friend && @user)
      friendShip=Friendship.find_by_user_id_and_friend_id(@user.id, friend.id) #checks that friendship exists
      if(friendShip)
        friendShip.type='ConfirmedFriendship' #changes friendship type to Confirmed
        respond_to do |format|
          if friendShip.save #creates friendship for friend as well as Confirmed
            friendShip=Friendship.find_by_user_id_and_friend_id(friend.id, @user.id)
            friendShip.type='ConfirmedFriendship'
            session[:user_id]=@user.id
            if friendShip.save #returns that friendship was successfully created
              format.html { redirect_to @user, notice: 'Friendship was successfully created.' }
              format.json { render json: {:created => 'true', :exists => 'true', :friends => 'false'}}
            else
              format.html { redirect_to @user, notice: 'Something went wrong!'}
              format.json { render json: {:created => 'false', :exists => 'true', :friends => 'false'}}
            end
          else
            format.html { redirect_to @user, notice: 'Something went wrong!'}
            format.json {render json: {:created => 'false', :exists => 'false', :friends => 'false'}}
          end
        end
      else
        respond_to do |format| #returns if freindship was never created - meaning never requested
          format.html { redirect_to @user, notice: 'Something went wrong! According to our records, this friendship was never requested!'}
          format.json {render json: {:created => 'false', :exists => 'false', :friends => 'false'}}
        end
      end
    else
      respond_to do |format| #returns if either friend or user do not exist
        format.html { redirect_to @user, notice: 'Something went wrong! According to our records, you do not exist!'}
        format.json {render json: {:created => 'false', :exists => 'false', :friends => 'false'}}
      end
    end
  end

  # PUT /friendships/1
  # PUT /friendships/1.json
  # updates the friendship
  def update
    @friendship = Friendship.find(params[:id]) #finds the friendship

    respond_to do |format|
      if @friendship.update_attributes(params[:friendship]) #attempts to update friendship attributes
        format.html { redirect_to @friendship, notice: 'Friendship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @friendship.errors, type: :unprocessable_entity }
      end
    end
  end

  # DELETE /friendships/1
  # DELETE /friendships/1.json
  # destroys the requested friendship
  def destroy
    #finds the user and friend to destroy
    @user=current_user
    friend = User.find_by_email(params[:email])
    if(friend)
      friendCheck=Friendship.find_by_user_id_and_friend_id(@user.id, friend.id) #if friendship exists
      if(friendCheck)
        #delete friendship both ways
        @friendship = @user.friendships.find_by_friend_id(friend.id)
        @friendship.destroy
        @friendship = friend.friendships.find_by_friend_id(@user.id)
        @friendship.destroy

        respond_to do |format| #return if deleted or not
        format.html { redirect_to root_url }
        format.json { render json: {:deleted => 'true'}}
        end
      else
        respond_to do |format|
        format.html { redirect_to root_url }
        format.json { render json: {:deleted => 'false'}}
        end
      end
    else
      respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render json: {:deleted => 'false'}}
      end
    end
  end
end
