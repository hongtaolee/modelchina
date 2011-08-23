class MakeupsController < ApplicationController
  layout "admin", :except => [:index,:show,:comment,:city,:all,:search,:tag]
  before_filter :login_required, :only=>['add_picture','destroy_picture','list', 'edit', 'new', 'create','update','destroy','comment','album']
  def index
    @title = "化妆师"
    @makeups = Makeup.find(:all, :order => 'read_count DESC' ,:include =>[:avata])
    @pages, @makeups = paginate_collection @makeups, :page => @params[:page], :per_page => 10
    @new_makeups = Makeup.find(:all, :order => 'created_at DESC', :limit => 6 ,:include =>[:avata])
    render :layout => 'default'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title = "化妆师列表" 
    @makeups = Makeup.find(:all, :conditions => ["user_id = ? ", current_user.id],:order => 'created_at DESC')
    @pages, @makeups = paginate_collection @makeups, :page => @params[:page], :per_page => 10
  end

  def show
    @makeup = Makeup.find(params[:id])
    @makeups = Makeup.find(:all, :order => 'read_count DESC', :limit => 6 ,:include =>[:avata])
    @makeup.update_attribute(:read_count,@makeup.read_count + 1)
    @tagged_items = Makeup.tags_count(:limit => 50, :conditions => [" makeups.id = ? ", @makeup.id ])
    @title = "化妆师秀—#{@makeup.name}" 
    render :layout=>'default'
  end

  def new
    @title = "添加化妆师" 
    @makeup = Makeup.new
  end

  def create
    @title = "添加化妆师" 
    @makeup = Makeup.new(params[:makeup])
    @makeup.user_id = current_user.id
    @makeup.province = params[:province]
    @makeup.city = params[:city]
    @makeup.avata = Avata.new(:data => @params[:data])    
    if @makeup.save
      @makeup.tag_with(params[:tags])
      flash[:notice] = "化妆师创建成功"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @makeup = Makeup.find(params[:id])
    self_required(@makeup)
    @title = "编辑化妆师-#{@makeup.name}" 
  end

  def update
    @makeup = Makeup.find(params[:id])
    @makeup.province = params[:province]
    @makeup.city = params[:city]
    @makeup.avata.update_image(@params[:data])
    if @makeup.update_attributes(params[:makeup])
      @makeup.tag_with(params[:tags])
      flash[:notice] = "化妆师资料更新成功"
      redirect_to :action => 'show', :id => @makeup
    else
      render :action => 'edit'
    end
  end

  def destroy
    Makeup.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
 
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each { |id| makeup.find(id.to_i).destroy}
    flash[:notice] = "化妆师成功删除"
    redirect_to :action => 'list'
  end 
  
  def comment
    @makeup = Makeup.find(params[:id])
    if @comment = @makeup.comments.create(params[:comment])
      render :update do |page|
        page.insert_html :bottom, 'comments', :partial=>'comment',:object => @comment
        page.visual_effect :blind_down, "comment_item_#{@comment.id}", :duration => 1
        page.visual_effect :highlight, "comment_item_#{@comment.id}", :duration => 3
      end
    else
      flash[:notice] = "Sorry，失败了"
      redirect_to_stored
    end   
  end
  
  def delete_comment
    @comment = Comment.find(params[:id])
    if @comment.destroy
      render :update do |page|
        page.visual_effect :blind_up, "comment_item_#{@comment.id}", :duration => 3      
#        page.remove "comment_item_#{@comment.id}"
      end
    else
      flash[:notice] = "Sorry，失败了"
      redirect_to_stored
    end
  end
  
  def rank
    @makeup = Makeup.find(params[:id])
    rank = @makeup.rank + params[:rank].to_i
    if @makeup.update_attributes(:rank_count => @makeup.rank_count + 1,:rank => rank )
      flash[:notice] = "评级成功"
      render(:partial => 'rank') 
    end   
  end
  
  def album
    @makeup = Makeup.find(params[:id])
    @title = "化妆师相册－#{@makeup.name}" 
    @makeup_picture = MakeupPicture.new
  end

  def city
    @title = "同城化妆师" 
	sql = "SELECT city,COUNT(*) AS count FROM makeups LEFT OUTER JOIN avatas ON avatas.makeup_id = makeups.id " 
	sql << "WHERE city <> '' "
    sql << " GROUP BY city "
	sql << " ORDER BY count DESC" 
	@city = Makeup.find_by_sql(sql)
	@gzmakeups=Makeup.find(:all,:conditions => ['city = ? ','广州'],:order => 'comments_count DESC',:limit => 6,:include => [:avata] )
	@bjmakeups=Makeup.find(:all,:conditions => ['city = ? ','北京'],:order => 'comments_count DESC',:limit => 6 ,:include => [:avata])
	@shmakeups=Makeup.find(:all,:conditions => ['city = ? ','上海'],:order => 'comments_count DESC',:limit => 6,:include => [:avata] )
    @tagged_items = Makeup.tags_count(:limit => 50)  
    render :layout => 'default'
  end
  
  def citysearch
    @title = "同城化妆师" 
	sql = "SELECT city,COUNT(*) AS count FROM makeups " 
	sql << "WHERE city <> '' "
    sql << " GROUP BY city "
	sql << " ORDER BY count DESC" 
	@city = Makeup.find_by_sql(sql)
 	@makeups=Makeup.find(:all,:conditions => ['city = ?',params[:id]],:order => 'comments_count DESC',:include => [:avata])
    @pages, @makeups = paginate_collection @makeups, :page => @params[:page], :per_page => 10
    @tagged_items = Makeup.tags_count(:limit => 50)  
    render :layout => 'default'
  end
  
  def tag
    @makeups = Makeup.find_tagged_with(:conditions => [" tags.name = ? ", params[:id]])
    @pages, @makeups = paginate_collection @makeups, :page => @params[:page], :per_page => 10 
    @tagged_items = Makeup.tags_count(:limit => 50,:conditions=>['makeups.sex = ?',2])    
    render :layout => 'default'
  end
  
  def search
    @title = "化妆师搜索" 
    unless params[:province]
      province = "no"
    end
    if params[:province] == '选择省份'
      province = "no"
      city = "no"
    end
    if params[:city] == "选择城市"
      city = "no"
    end
    unless params[:city]
      city = "no"
    end
	sql = "SELECT makeups.id,province,city,sex,name,rank_count,rank,read_count,comments_count FROM makeups LEFT OUTER JOIN avatas ON avatas.makeup_id = makeups.id " 
	sql << "WHERE avatas.id <> ''"
	sql << "  AND province = '#{params[:province]}'" unless province == 'no'
	sql << "  AND city = '#{params[:city]}'" unless city == 'no'
	sql << "  AND sex = #{params[:sex]}" unless params[:sex].blank?
	sql << " ORDER BY comments_count DESC" 
	@result = Makeup.find_by_sql(sql)
	@pages, @makeups = paginate_collection @result, :page => @params[:page], :per_page => 10
	@new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:limit => 10)
    @tagged_items = Makeup.tags_count(:limit => 50)  
	render :layout => 'default'  
  end
  
  def all
    @title = "全部化妆师" 
    @makeups = Makeup.find(:all,:order => 'created_at DESC',:include => [:avata])
    @pages, @makeups = paginate_collection @makeups, :page => @params[:page], :per_page => 10
    @new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:limit => 10)
    @tagged_items = Makeup.tags_count(:limit => 50)   
    render :layout => 'default'
  end
  
  def add_picture
    @makeup = Makeup.find(params[:id])
    @makeup_picture = MakeupPicture.new(params[:makeup_picture])
    @makeup_picture.picture = Picture.new(:data => params[:data])
    @makeup.makeup_pictures << @makeup_picture
    @makeup.pictures_count = @makeup.pictures_count + 1
    if @makeup.save
      redirect_to :controller => 'makeups',:action => 'album',:id => @makeup
    end
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
  def destroy_picture
    @makeup = Makeup.find(params[:id])
    @makeup.makeup_pictures[params[:position].to_i - 1].destroy
    @makeup.update_attribute(:pictures_count, @makeup.pictures_count - 1)
    redirect_to :controller => 'makeups',:action => 'album',:id => @makeup
  end
  
  def get_picture
    @picture = MakeupPicture.find(:first,:conditions=>['makeup_id = ? and position = ?',params[:makeup],params[:position]])
    render :update do |page|
      page.replace_html 'display_image',
        :partial => 'get_picture'
    end
  end  
  
end
