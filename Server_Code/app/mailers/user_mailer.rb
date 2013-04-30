class UserMailer < ActionMailer::Base
  default from: "mapyourmoments.corp@gmail.com"

  def welcome(user)
    @user = user
    mail(:to => user.email, :subject => "Thanks for signing up with MyM")
  end
  def confirmation(user,friend)
    @user=user
    @friend=friend
    mail(:to => friend.email, :subject => "MyM - Friend Request")
  end
end
