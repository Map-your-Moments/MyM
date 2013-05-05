class UserMailer < ActionMailer::Base
  default from: "mapyourmoments.corp@gmail.com" #declares originating email address
  
  #creation for user welcome email with to address and subject
  def welcome(user)
    @user = user
    mail(:to => user.email, :subject => "Thanks for signing up with MyM")
  end

  #creation of confirmation email with user, friend, and subject
  def confirmation(user,friend)
    @user=user
    @friend=friend
    mail(:to => friend.email, :subject => "MyM - Friend Request")
  end
end
