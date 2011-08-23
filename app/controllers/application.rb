#require 'gettext/rails'
require "digest/sha1"
require_dependency "common"
require_dependency "enum"
require 'RMagick' 
include Magick
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  model :user 
  helper :application
#  init_gettext "global"
  before_filter :setup_local, :setup_user,:current_user, :check_code
  after_filter :log_action, :remember_location
  local_addresses.clear # 127.0.0.1 will also produce ExceptionNotification  
  
  def current_user
    @current_user ||= session[:user_id] ? User.find(session[:user_id]) : nil
  end

#@pages, @users = paginate_collection User.find_custom_query, :page => @params[:page]
  def paginate_collection(collection, options = {})
    default_options = {:per_page => 10, :page => 1}
    options = default_options.merge options
    
    pages = Paginator.new self, collection.size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], collection.size].min
    slice = collection[first...last]
    return [pages, slice]
  end
  
  def check_block
    if BlockedIp.blocked?(request.remote_ip)
      render_text 'blocked', 403
      return false
    end
  end
  
  def setup_url_generator
    UrlGenerator.controller = self
  end
 
  @@REMEMBER_NOT = ['public/notice','user/login','user/signup','user/edit_password','models/get_picture','photographers/get_picture','makeups/get_picture','avatas/show','pictures/show','topics/delete','topics/undelete','topics/delete_post','topics/undelete_post']
  def remember_location
    if @response.headers['Status'] == '200 OK'
      @session[:return_to] = url_for unless @@REMEMBER_NOT.include? controller_name+'/'+action_name
    end
  end
    
  def setup_local
    if request.xhr? 
      @headers["Content-Type"] ||= "text/javascript; charset=utf-8" 
    else 
      @headers["Content-Type"] ||= "text/html; charset=utf-8" 
    end 
    cookies["lang"] = "zh"
  end
  
  def setup_user
    unless session[:checked]    
      unless session[:user_id]
        if cookies[:auth_token]
          u = User.find_by_remember_token(cookies[:auth_token])
          if u && !u.remember_token_expires.nil? && Time.now < u.remember_token_expires 
            
            # 更新最后登录信息
            u.last_login = Time.now
            u.last_ip = request.remote_ip
            u.login_times = u.login_times.next
            u.save(false)
            
            session[:user_id] = u.id
            session[:user_email] = u.email
            session[:user_name] = u.name
          end
        end
      end
  
      logger.info("check session cookies")
      loginSession = Digest::SHA1.hexdigest(Time.new.ctime + Enum::LOGIN_SESSION + request.remote_ip)
      loginUser = Enum::ANONYMOUS
      unless session[:user_id]
        cookies[:login_session] = { :value => loginSession, :expires => 365.days.from_now }
        session[:login_first] = true
      else
        loginUser = session[:user_id]
      end
      
      logger.info("#{session[:login_session]}")
      logger.info("write login_log")
      session[:login_session] = loginSession
      if session[:user_id] || !is_spider
        loginLog = LoginLog.new
        loginLog.user_id = loginUser
        loginLog.session_id = loginSession
        loginLog.remote_ip = request.remote_ip
        loginLog.created_date = Time.new.strftime("%Y%m%d").to_i
        
        if session[:invite_code]
          iid = Invite.find_by_code(session[:invite_code])
          loginLog.owner = iid if iid
        elsif session[:referral_code]
          rid = Referral.find_by_code(session[:referral_code])
          loginLog.owner = rid if rid
        end
        loginLog.save(false)
      end
      
      session[:checked] = true
    end
  end
  
  def log_action
    uid = (session[:user_id] ? session[:user_id] : Enum::ANONYMOUS) 
    if session[:user_id] || !is_spider
      aLog = ActionLog.new
      aLog.user_id = uid
      aLog.request_uri = request.request_uri
      aLog.action_uri = "#{controller_name}/#{action_name}"
      aLog.remote_ip = request.remote_ip
      aLog.created_date = Time.new.strftime("%Y%m%d").to_i
      aLog.session_id = session[:login_session]
      aLog.save(false)
    end
  end
  
  def check_code
    session[:invite_code] = params[:invite_code] unless params[:invite_code].blank?
    session[:referral_code] = params[:referral_code] unless params[:referral_code].blank?
  end

  def redirect_to_stored  
    begin
      redirect_to_url(@session[:return_to] || '/')
    rescue App::SecurityError
      redirect_to_url('/')
    end
  end
  
  def login_required
    if session[:user_id]
      @user = User.find(session[:user_id])
      return true
    end
    flash[:warning]='您必须先登录，才能继续操作.如果还没有Model-china 帐户，可以<a href="signup">在此注册</a>。'
    session[:return_to]=request.request_uri
    redirect_to :controller => "user", :action => "login"
    return false 
  end
  
  def admin_required
    if @current_user.role == 'admin'
      return true
    end
    flash[:warning]="您没有权限执行该操作,请检查是否以正确的用户身份登录,如果有其他问题,可以在<a href='http://www.model-china.cn/group/show/1'>model-china小组</a>向管理员反馈。"
    session[:return_to]=request.request_uri
    redirect_to :controller => "user", :action => "login"
    return false   
  end
  
  def self_required(object)
    if @current_user.id == object.user_id || @current_user.role == 'admin'
      return true
    end
    flash[:warning]="您没有权限执行该操作,请检查是否以正确的用户身份登录,如果有其他问题,可以在<a href='http://www.model-china.cn/group/show/1'>model-china小组</a>向管理员反馈。"
    session[:return_to]=request.request_uri
    redirect_to :controller => "user", :action => "login"
    return false    
  end
  
end

module App

  # Security error. Controllers throw these in situations where a user is trying to access a
  # function that he is not authorized to access. 
  # Normally, RForum does not show URLs that would allow the user to access such features.
  class SecurityError < StandardError
  end

end

module ActionView 

  module Helpers 

    module ActiveRecordHelper 

      def error_messages_for(object_name, options = {}) 
        options = options.symbolize_keys 
        object = instance_variable_get("@#{object_name}") 
        unless object.errors.empty? 
          content_tag("div", 
            content_tag( 
              options[:header_tag] || "h2", 
              "非常抱歉，发生了如下错误" 
            ) + 
            content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }), 
            "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation" 
          ) 
        end 
      end 

    end 
  end 
end 
