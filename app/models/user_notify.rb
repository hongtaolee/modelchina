require 'action_mailer'
require 'received_mail'
class UserNotify < ActionMailer::Base
  def signup(user, password, url=nil)
    setup_email(user)

    # Email header info
    @subject += "#{App.CONFIG[:app_name]}:"

    # Email body substitutions
    @body["name"] = "#{user.firstname} #{user.lastname}"
    @body["login"] = user.login
    @body["password"] = password
    @body["url"] = url || App::CONFIG[:app_url].to_s
    @body["app_name"] = App::CONFIG[:app_name].to_s
  end

  def forgot_password(email,user,newpass)
    setup_email(user)

    # Email header info
    @subject += "忘记密码通知"

    # Email body substitutions
    @body["login"] = user
    @body["newpass"] = newpass
    @body["app_name"] = App::CONFIG[:app_name].to_s
  end

  def change_password(user, password, url=nil)
    setup_email(user)

    # Email header info
    @subject += "修改密码通知"

    # Email body substitutions
    @body["name"] = "#{user.firstname} #{user.lastname}"
    @body["login"] = user.login
    @body["password"] = password
    @body["url"] = url || App::CONFIG[:app_url].to_s
    @body["app_name"] = App::CONFIG[:app_name].to_s
  end

  def pending_delete(user, url=nil)
    setup_email(user)

    # Email header info
    @subject += "用户删除通知"

    # Email body substitutions
    @body["name"] = "#{user.firstname} #{user.lastname}"
    @body["url"] = url || App::CONFIG[:app_url].to_s
    @body["app_name"] = App::CONFIG[:app_name].to_s
    @body["days"] = App::CONFIG[:delayed_delete_days].to_s
  end

  def delete(user, url=nil)
    setup_email(user)

    # Email header info
    @subject += "删除用户通知"

    # Email body substitutions
    @body["name"] = "#{user.firstname} #{user.lastname}"
    @body["url"] = url || App::CONFIG[:app_url].to_s
    @body["app_name"] = App::CONFIG[:app_name].to_s
  end
  
protected

  def setup_email(user)
    @user = User.find_by_name(user)
    @recipients = "#{@user.email}"
    @from       = App::CONFIG[:email_from].to_s
    @subject    = "[#{App::CONFIG[:app_name]}] "
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=#{App::CONFIG[:mail_charset]}; format=flowed"
  end
end
