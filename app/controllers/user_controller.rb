require 'application'
class UserController < ApplicationController
  layout "default" , :except => ['show','change_password','edit','list']
  before_filter :login_required, :only=>['list','change_status','show', 'edit', 'change_password', 'hidden','home','logout']
  before_filter :admin_required, :only => ['list','change_status']
  skip_before_filter :setup_user, :only => ['logout']
  def login
    @title = "用户登录"  
    if request.post?    
      if @user = User.authenticate(@params[:user][:name], @params[:user][:password])
        session[:user_id] = @user.id
        session[:user_name] = @user.name
        session[:user_email] = @user.email
        auto_login
        
        # 更新最后登录信息
        @user.last_login = Time.now
        @user.last_ip = request.remote_ip
        @user.login_times = @user.login_times.next
        @user.save(false)
        
        cookies[:login_session] = { :value => "login_session", :expires => Time.now-86400}
        cookies.delete :login_session
        
        # generate new session id again
        session[:checked] = nil
        session[:login_first] = nil
        session[:login_session] = nil
        
        flash[:notice]  = "成功登录"
        redirect_to_stored
      else
        flash[:warning] = "登录失败"
      end
    end
  end

  def forgot_password
    if request.post?
      u = User.find_by_email(@params[:user][:email])
      if u and u.send_new_password
        flash[:notice]  = "新密码将要通过Email发送给您，请查收"
        redirect_to :action=>'login'
      else
        flash[:notice]  = "不能发送密码"
      end
    end
  end

  def logout
    current_user.forget_me if current_user
    session[:user_id] = nil
    cookies.delete :auth_token
    cookies.delete :login_session
    redirect_to_stored
  end
  
  def signup
     @user = User.new(@params[:user])
     if request.post?
       @user.avata = Avata.new(:data => @params[:data])
       case @user.category
       when 1
         @user.models << Model.new(:name => @user.name)
       when 2
         @user.enterprise = Enterprise.new(:name => @user.name)
       when 3
         @user.photographers << Photographer.new(:name => @user.name)
       when 4
         @user.makeups << Makeup.new(:name => @user.name)      
       else
       
       end
       
      if @user.save
        if session[:invite_code]
          @user.source = Enum::USER_SOURCE_INVITE
          @user.source_detail = session[:invite_code]
        elsif session[:referral_code]
          @user.source = Enum::USER_SOURCE_REFERRAL
          @user.source_detail = session[:referral_code]
        end
#        @user.captcha_id = params[:user][:captcha_id]
#        @user.captcha_validation = params[:user][:captcha_validation]
        @user.created_date = Time.now.strftime("%Y%m%d").to_i
        session[:user_id] = User.authenticate(@user.name, @user.password).id
        auto_login
        
        session[:invite_code] = nil if session[:invite_code]
        session[:referral_code] = nil if session[:referral_code]
        
        flash[:notice] = "注册成功"
        redirect_to :action => "show"          
      else
        @user.password = ""
#        @user.captcha_validation = ""
        @user.password_confirmation = ""
        flash[:notice] = "注册失败"
      end
    end
  end

  def edit
    @user = current_user
    if request.post?
      @user.update_attributes(params[:user])
      @user.avata.update_image(@params[:data])
      if @user.save
        flash[:notice]= "用户资料更新成功!"
        redirect_to :controller=>'user',:action=>'show'
      end
    else
        render :layout => 'admin'
    end
  end
  
  def show
    @user = current_user
    render :layout => 'admin'
  end
  
  def change_password
    @user = current_user 
    render :layout => 'admin'     
  end
  
  def edit_password
    @user = current_user
    @user.update_attributes(:password => params[:user][:password], 
                :password_confirmation => params[:user][:password_confirmation])
    if @user.save
      render :update do |page|
        page.hide 'forms'
        page.replace_html 'warning','修改密码成功！'
      end
    else
      render :update do |page|
        page.replace_html 'warning','修改密码失败！'      
      end
    end
  end
    
  def list
    @title = "用户列表" 
    @users = User.find(:all,:order=>'created_at DESC')
    @pages, @users = paginate_collection @users, :page => @params[:page], :per_page => 50
    render :layout => 'admin'
  end

  def home
    @title = "我的门户"
    redirect_to :controller=>'user',:action=>'show'
  end
  
  def welcome
    @user=User.find(params[:id])
    category = @user.category.to_i
    case category
    when 1
      @model = Model.find_by_user_id(@user.id)
      redirect_to :controller => 'models',:action=>'show',:id=>@model.id
    when 3
      @photographer = Photographer.find_by_user_id(@user.id)
      redirect_to :controller => 'photographers',:action=>'show',:id=>@photographer.id
    when 4
      @makeup = Makeup.find_by_user_id(@user.id)
      redirect_to :controller => 'makups',:action=>'show',:id=>@makeup.id            
    else
      redirect_to :controller=>'enterprises',:action =>'show',:id=>@user.enterprise.id
    end  
  end
  
 # 历史遗留问题，流量转换
  def album
    redirect_to :controller=>'public',:action=>'index' 
  end
  
  def change_status
    @user = User.find(params[:id])
    if request.post?
      @user.models.first.update_attribute(:status ,params[:status])
      if @user.models.first.save
        redirect_to :action => 'list'
      
      end
    end
  end
   
  protected
  
  def auto_login
    if params[:auto_login] == "1"
      current_user.remember_me
      cookies[:auth_token] = { :value => current_user.remember_token , :expires => current_user.remember_token_expires }
    end  
  end
end