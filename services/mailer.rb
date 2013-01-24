class Notifier < ActionMailer::Base
  default :from => 'josh.stein107@gmail.com'
  def welcome(recipient)
    @recipient = recipient
    @user = recipient 
    @url = "http://localhost:9292/token/#{@user.token}"
    mail(:to => 'josh.stein107@gmail.com',
         :subject => "[Signed up] Welcome #{recipient.email}"
         )
  end
end

