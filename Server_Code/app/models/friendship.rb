class Friendship < ActiveRecord::Base
  attr_accessible :friend_id, :user_id #attributes for a friendship
  belongs_to :user #who a friendship belongs to 
  belongs_to :friend, :class_name => "User" #additional ownsership of friendship
end
#creates different types of friendships
class PendingFriendship < Friendship
end
class ConfirmedFriendship < Friendship
end
