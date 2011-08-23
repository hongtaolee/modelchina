class GroupsController < ApplicationController
  layout 'default',:except=>['my']
  before_filter :login_required, :only=>['new', 'create','update','destroy','add','exit','post','edit']
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title = "兴趣小组" 
    @groups = Group.find(:all,:order =>'member_count DESC' ,:limit => 12)
    @new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @topics = Topic.find(:all,:conditions => ['deleted = ?',false],:order =>'created_at DESC',:limit => 20)
  end

  def my
    @title = "我的小组" 
    @members = Member.find(:all,:conditions=>['user_id = ? ',current_user.id],:include=>[:group],:order =>'members.created_at DESC')
    @topics = Topic.find(:all,:conditions=>['user_id = ? ',current_user.id],:order =>'created_at DESC')
    @pages, @topics = paginate_collection @topics, :page => @params[:page], :per_page => 50  
    render :layout=>'admin'
  end
  
  def all
    @title = "全部兴趣小组" 
    @groups = Group.find(:all,:order =>'member_count DESC')
    @new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @pages, @groups = paginate_collection @groups, :page => @params[:page], :per_page => 100 
  end

  def search
    @title = "兴趣小组－搜索" 
 	sql = "SELECT * FROM groups " 
	sql << "WHERE name like '%#{params[:search]}%' "
    sql << " OR description like '%#{params[:search]}%' "
	sql << " ORDER BY member_count DESC" 
	@groups = Group.find_by_sql(sql)
    @new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @pages, @groups = paginate_collection @groups, :page => @params[:page], :per_page => 100 
  end

  def show
    @group = Group.find(params[:id])
    @title = "兴趣小组－#{@group.name}" 
    @members = Member.find(:all,:conditions=>['group_id = ? ',@group.id],:include=>:user,:order =>'members.created_at DESC' ,:limit => 6)
    @all_topics = Topic.find(:all,:conditions=>['status = ? ',6 ],:order =>'created_at DESC')
    @top_topics = Topic.find(:all,:conditions=>['group_id = ? and status = ? ',@group.id ,5],:order =>'created_at DESC')
    @topics = Topic.find(:all,:conditions=>['group_id = ? and status = ?',@group.id,0],:order =>'created_at DESC')
    @tagged_items = Group.tags_count(:limit => 50, :conditions => [" groups.id = ? ", @group.id ])
    @pages, @topics = paginate_collection @topics, :page => @params[:page], :per_page => 30        
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end

  def new
    @title = "建立新的兴趣小组" 
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.admin = current_user.id
    @group.avata = Avata.new(:data => @params[:data])
    if @group.save
      @group.tag_with(params[:tags])
      @member = Member.new
      @member.user_id = current_user.id
      @member.group_id = @group.id
      if @member.save
        flash[:notice] = "兴趣小组成功创建"
        redirect_to :action => 'list'
      else
        render :action => 'new'     
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
    @title = "编辑小组信息-#{@group.name}" 
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public'
  end

  def update
    @group = Group.find(params[:id])
    if @group.avata
      @group.avata.update_image(@params[:data])
    else
      @group.avata = Avata.new(:data => @params[:data])
    end
    if @group.update_attributes(params[:group])
      @group.tag_with(params[:tags])
      flash[:notice] = "小组资料更新成功"
      redirect_to :action => 'show', :id => @group
    else
      render :action => 'edit'
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def add
    @group = Group.find(params[:id])
    @member=Member.new
    @member.user_id = current_user.id
    @member.group_id = @group.id
    if @member.save
      @group.update_attribute(:member_count,@group.member_count+1)
      flash[:notice] = "欢迎您成为 #{@group.name}的一员"
      @members = Member.find(:all,:conditions=>['group_id = ? ',@group.id],:order =>'members.created_at DESC' ,:include=>:user,:limit => 10)
      render :update do |page|
        page.replace_html 'group_operation',:partial=>'group_operation'
        page.replace_html 'add_member',:partial=>'add_member'       
      end
    else
      flash[:notice] = "Sorry，失败了"
      render :action=>'show',:id=>@group.id  
    end
  end
  
  def exit
    @group = Group.find(params[:id])
    @member = Member.find(:first,:conditions=>['user_id =? and group_id =?',current_user.id,params[:id]])
    if @member.destroy
      @group.update_attribute(:member_count,@group.member_count+1)
      flash[:notice] = "您已经成功退出了 #{@group.name}"
      @members = Member.find(:all,:conditions=>['group_id = ? ',@group.id],:order =>'members.created_at DESC' ,:include=>:user,:limit => 10)
      render :update do |page|
        page.replace_html 'group_operation',:partial=>'group_operation'
        page.replace_html 'add_member',:partial=>'add_member'       
      end
    else
      flash[:notice] = "Sorry，失败了"
      render :action=>'show',:id=>@group.id        
    end
    
  end
  
  def post
    @group = Group.find(params[:id])
    @group.topic_count = @group.topic_count + 1
    @group.post_count = @group.post_count + 1
    @topic = Topic.new(params[:topic])
    @topic.user_id = current_user.id
    @topic.last_reply = Time.now
    @topic.posts << Post.new(:content => params[:post][:content],
                           :user_id => @topic.user_id)    
    @group.topics << @topic
    if @group.save
      flash[:notice] = "主题创建成功"
      redirect_to :action=>'show',:id=>@group.id
    else
      flash[:notice] = "Sorry，失败了……" 
    end    
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public' 
  end
 
  def member
    @group = Group.find(params[:id])
    @title = "兴趣小组-#{@group.name}-成员列表" 
    @members = Member.find(:all,:conditions=>['group_id = ? ',@group.id],:include=>:user,:order =>'members.created_at DESC')  
    @pages, @members = paginate_collection @members, :page => @params[:page], :per_page => 100          
  end
end
