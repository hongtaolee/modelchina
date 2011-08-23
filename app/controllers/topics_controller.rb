class TopicsController < ApplicationController
  layout 'default'
  before_filter :login_required, :only=>['new', 'create','update','edit','destroy','post']
  
  def index
    list
    render :action => 'list'
  end

  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title = "全部话题"
    @topics = Topic.find(:all,:order=>'created_at DESC')
    @pages, @topics = paginate_collection @topics, :page => @params[:page], :per_page => 100 
  end

  def show
    @topic = Topic.find(params[:id])
    @topic.update_attribute(:read_count,@topic.read_count+1)
    @group = Group.find(@topic.group_id)
    @others = Topic.find(:all,:conditions=>['id < ?',@topic.id],:order => 'created_at DESC',:limit => 20)  
    @title = "兴趣小组－#{@group.name}-#{@topic.title}"
    @post = Post.new
  end

  def new
    @group = Group.find(params[:id])
    @title = "兴趣小组－#{@group.name}-发布新话题"
    @topic = Topic.new
    @post = Post.new
  end

  def create
    @topic = Topic.new(params[:topic])
    @topic.posts << Post.new(:content => params[:post][:content])
    if @topic.save
      flash[:notice] = "主题创建成功"
      redirect_to :controller=>'groups',:action => 'show',:id=>@topic.group_id
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
    @title = "编辑话题-#{@topic.title}"
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "主题成功更新"
      redirect_to :action => 'show', :id => @topic
    else
      render :action => 'edit'
    end
  end

  def delete
    @topic = Topic.find(params[:id])
    @topic.update_attribute(:deleted,true)
    render :update do |page|
      page.remove_html "tr_topic_#{@topic.id}"
      #page.replace_html "topic_#{@topic.id}","<del><a href=\"/topics/show/#{@topic.id}\">#{@topic.title}</a></del>"
      #page.replace_html "operation_#{@topic.id}",:partial => 'operation'
    end
  end
  
  def undelete
    @topic = Topic.find(params[:id])
    @topic.update_attribute(:deleted,false)
    render :update do |page|
      page.replace_html "topic_#{@topic.id}","<a href=\"/topics/show/#{@topic.id}\">#{@topic.title}</a>"
      page.replace_html "operation_#{@topic.id}",:partial => 'operation'
    end
  end
  
  def delete_post
    @post = Post.find(params[:id])
    @post.update_attribute(:deleted,true)
    render :update do |page|
      page.replace_html "post_#{@post.id}","<del>#{@post.content}</del>"
      page.replace_html "delete_#{@post.id}","(<a href='#' onclick=\"new Ajax.Request('/topics/undelete_post/#{@post.id}', {asynchronous:true, evalScripts:true}); return false;\">undelete</a>)"
    end
  end
  
  def undelete_post
    @post = Post.find(params[:id])
    @post.update_attribute(:deleted,false)
    render :update do |page|
      page.replace_html "post_#{@post.id}","#{@post.content}"
      page.replace_html "delete_#{@post.id}","(<a href='#' onclick=\"new Ajax.Request('/topics/delete_post/#{@post.id}', {asynchronous:true, evalScripts:true}); return false;\">delete</a>)"
    end
  end
  
  def post
    @topic = Topic.find(params[:post][:topic_id])
    @group = Group.find(@topic.group_id)
    @post = Post.new(params[:post])
    @post.parent_id = @topic.posts.first.id
    if @post.save
      @topic.update_attribute(:post_count,@topic.post_count + 1)
      @group.update_attribute(:post_count,@group.post_count + 1)
      flash[:notice] = "回帖成功"
      render :update do |page|
        page.insert_html :bottom, 'posts', :partial=>'post'
        page.visual_effect :highlight, "new_post_#{@post.id}", :duration => 3
      end
    else
      flash[:notice] = "Sorry，失败了"
      render(:partial => 'post') 
    end    
  end
  
  def set_status
    @topic = Topic.find(@params[:id])
    Topic.update(@topic.id, :status => params[:status])
    redirect_to_stored
  end
  
  def cancel_status
    @topic = Topic.find(@params[:id])
    Topic.update(@topic.id, :status => 0)
    redirect_to_stored
  end
  
end
