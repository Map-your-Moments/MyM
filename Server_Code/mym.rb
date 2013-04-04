require 'rubygems'
gem 'aws-sdk'
require 'aws-sdk'
require 'optparse'
require 'json'
require 'open-uri'

class MyM
	# registers a new user with the system
	def self.register_user
	end

	# authenticates an existing user with the system
	def self.authenticate_user
	end

	# posts a new moment to a user's map
	def self.post_user_moment
	end

	# marks a user as following another user
	def self.follow_user
	end

	# registers a request with a user that another user wishes to be their friend
	def self.friend_user
	end

	# responds to a friend request (affirm/deny)
	def self.respond_friend
	end

	# posts a comment to an existing moment
	def self.comment_moment
	end

	# fetches a hash of all moments belonging to a user
	def self.fetch_moment_list
	end

	# fetches a full moment (content + comments)
	def self.fetch_moment
	end

end