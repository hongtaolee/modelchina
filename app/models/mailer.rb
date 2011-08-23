require 'action_mailer'
require 'digest/md5'
require 'received_mail'

class Mailer < ActionMailer::Base

  def registration_mail(user, password, login_url)
    setup_email(user)
    @subject += "欢迎您" + App::CONFIG[:site_name]
    @body = { 'user' => user, 'password' => password, 'login_url' => login_url }
  end
  
  def reset_password(user, reset_password_url)
    setup_email(user)
    @subject += "重设密码"
    @body['user'] = user
    @body['reset_password_url'] = reset_password_url
  end

  def user_message(from, to, text)
    setup_email(to)
    @from = from.email
    @subject += "消息来自" + from.name
    @body['text'] = Wraptools.wrap_ff(text, 72)
    @body['from'] = from
    @body['to'] = to
  end

  def delete_post_notification(post)
    setup_email(post.author)
    @body['post'] = post
  end

  def ml_post(post)
    unless post.topic.forum.list_address
      raise RuntimeError
    end
  
    footer = "\n\n-- \nPosted via http://www.ruby-forum.com/."
    @body = post.text + footer

    if post.author.guest?
      @from = (post.author.guest_name || 'Guest').dup
      @from << " <" + (post.author.guest_email || ("forumpost@" + App::CONFIG[:hostname])) + ">"
    else
      @from = "#{post.author.name} <#{post.author.email}>"
    end
    
    @subject = post.subject
    @recipients = post.topic.forum.list_address
    @sent_on = post.created_at
   
    @headers['Content-Type'] = "text/plain; charset=#{App::CONFIG[:mail_charset]}; format=flowed"
    @headers['reply-to'] = post.topic.forum.list_address
    #@headers["bcc"] = (users.collect { |u| u.email }).join ","
    @headers['sender'] = @headers['errors-to'] = App::CONFIG[:bounce_address]
    @headers['message-id'] = '<' + post.messageid + '>'

    if post.parent
      @headers['in-reply-to'] = '<' + post.parent.messageid + '>'
      @headers['references'] = post.get_references
    end

    if headers = post.topic.forum.add_mail_headers
      headers.each_line do |line|
        key, value = line.split(/\s*:\s*/, 2)
        @headers[key] = value
      end
    end
  end

  def receive(email)
    email.extend(ReceivedMail)
    email
  end

  def self.process_email(raw)
    email = self.receive(raw)
    unless App::CONFIG[:accept_mail_from_guests]
      if email.from_guest?
        # TODO: bounce
        raise 'email from guest'
      end
    
      if email.from_unauthorized_user?
        # TODO: bounce
        raise 'email from unauthorized user'
      end
    end

    email.create_post
  end

protected

  def setup_email(user)
    @recipients = user.email
    @subject = "[#{App::CONFIG[:site_name]}] "
    @from = App::CONFIG[:site_email]
    @headers['Content-Type'] = "text/plain; charset=#{App::CONFIG[:mail_charset]}; format=flowed"
  end

  def template_path
    template_root + "/" + Inflector.underscore(self.class.name) + "/" + App::CONFIG[:default_language]
  end

end
