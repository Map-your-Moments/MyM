class UserMailer < ActionMailer::Base
  default from: "mapyourmoments.corp@gmail.com"

  def welcome(user)
    @user = user
    mail(:to => user.email, :subject => "Thanks for signing up with MyM")
  end
end
