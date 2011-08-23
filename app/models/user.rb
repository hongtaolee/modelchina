require 'digest/md5'
class User < ActiveRecord::Base
  has_many :members
  has_one :avata , :dependent => :destroy
  has_many :models, :dependent => :delete_all
  has_many :makeups, :dependent => :delete_all
  has_many :photographers, :dependent => :delete_all
  has_many :messages, :dependent => :delete_all
  has_one :enterprise, :dependent => :destroy
#  validates_captcha :on => :create
  validates_length_of :name, :within => 3..20
  validates_presence_of :name, :email
  validates_presence_of :password, :on => :create,:message => "不能为空"
  validates_presence_of :password_confirmation, :on => :create,:message => "不能为空"
  validates_uniqueness_of :name, :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, 
            :message => "无效的Email地址"   
  attr_protected :id,:salt
  attr_accessor :password, :password_confirmation
  attr_accessor :cookie
  
  def self.authenticate(name, password)
    raise ArgumentError if name.nil?
    raise ArgumentError if password.nil?  
    u=find(:first, :conditions=>["name = ?", name])
    return nil if u.nil?
    return u if User.encrypt(password, u.salt)==u.hashed_password
    nil
  end  

  def password=(pass)
    @password=pass
    self.salt = User.random_string(10) if !self.salt?
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  def remember_me
    self.remember_token_expires = 2.weeks.from_now
    self.remember_token = Digest::MD5.hexdigest("#{self.email}--#{self.remember_token_expires}")
    self.save_with_validation(false)
  end

  def forget_me
    self.remember_token_expires = nil
    self.remember_token = nil
    self.save_with_validation(false)
  end
          
  def send_new_password
    new_pass = User.random_string(10)
    self.password = self.password_confirmation = new_pass
    self.save
    UserNotify.deliver_forgot_password(self.email, self.name, new_pass)
  end

  def is_member(group)
    if Member.find(:first,:conditions=>['user_id =? and group_id =?',self.id,group])
      return true
    else
      false
    end
  end
  
  def is_friend(friend)
    if self.id == friend
      return true
    else
      if Fav.find(:first,:conditions=>['user_id =? and friend_id =?',self.id,friend])
        return true
      else
        false
      end
    end
  end
  
  protected

  def self.encrypt(pass, salt)
    Digest::MD5.hexdigest(pass+salt)
  end

  def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def before_validation_on_create
    %w(name email).each do |attr|
      self[attr] = self[attr].to_s.strip.squeeze(' ').chomp 
    end

    self.name.downcase!
    self.email.downcase!
    
  end
  
end

