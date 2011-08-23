class MessagesController < ApplicationController
  layout "admin",:except => ['send_to']
  before_filter :login_required, :only=>['send_to','list', 'edit', 'new', 'create','update','destroy','delete','reply','show']  
  def list
    @title = "我的消息"
    @messages = Message.find(:all, :conditions => ["user_id = ? or user_id = ? ", current_user.id, '0'],:order => 'created_at DESC')
    @pages, @messages = paginate_collection @messages, :page => @params[:page], :per_page => 10
  end
  
  def show
    @message = Message.find(params[:id])
    @created_at = @message.created_at.strftime "%Y-%m-%d %H:%M"
    Message.update(@message.id, {:status => true})
    render(:update) do |page|
      page.send :record, "Element.removeClassName($$('ul#message_#{@message.id}').first(), 'no_read')"  
      page.replace_html 'message_show' ,:partial => 'show'
    end
  end
  
  def new
    @message = Message.new 
  end
  
  def send_to
    @message = Message.new
    @user = User.find(params[:id])
    @message.receive_name = @user.name
    render :layout => 'default'
  end
  
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each do |id|
      @message = Message.find(id.to_i)
      if self_required(@message)
        @message.destroy
      else
        @error = 1
      end
    end
    if @error == 1
      flash[:notice] = "消息删除失败"
    else
      flash[:notice] = "消息删除成功"    
    end
    redirect_to :controller => 'messages', :action => 'list'
  end
  
  def reply
    @message = Message.new(params[:message])
    @message.send_id = current_user.id
    @message.send_name = current_user.name
    @message.user_id = User.find_by_name(params[:message][:receive_name]).id
    if @message.save
      Message.update(params[:from], {:reply => true})
      flash[:notice] = "消息发送成功"
      redirect_to :controller => 'messages', :action => 'list'
    end  
  end
  
  def create
    @message = Message.new(params[:message])
    @message.send_id = current_user.id
    @message.send_name = current_user.name
    @message.user_id = User.find_by_name(params[:message][:receive_name]).id
    if @message.save
      flash[:notice] = "消息新建成功"
      redirect_to :controller => 'messages', :action => 'list'
    end
  end
  
  def edit
    @message = Message.find(params[:id])
  end
  
  def update
    @message = Message.find(params[:id])
    if params[:btn_cancel]
      @message.attributes = params[:message]
      render :action => 'edit'
    elsif @message.update_attributes(params[:message])
      flash[:notice] = "消息更新成功"
      redirect_to :action => 'show', :id => @message
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    if params[:btn_cancel]
      redirect_to :action => 'list'
    else
      @message = Message.find(params[:id])
      if self_required(@message)
        @message.destroy
      else
      redirect_to :action => 'list'
      end
    end
  end
end
