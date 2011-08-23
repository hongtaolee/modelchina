class PhotographersController < ApplicationController
  layout "admin", :except => [:index,:show,:comment,:city,:all,:search,:tag]
  before_filter :login_required, :only=>['add_picture','destroy_picture','list', 'edit', 'new', 'create','update','destroy','comment','album']
  def index
    @title = "摄影师"
    @photographers = Photographer.find(:all, :order => 'read_count DESC',:include =>[:avata])
    @pages, @photographers = paginate_collection @photographers, :page => @params[:page], :per_page => 10
    @new_photographers = Photographer.find(:all, :order => 'created_at DESC', :limit => 6 ,:include =>[:avata])
    render :layout => 'default'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title = "摄影师列表" 
    @photographers = Photographer.find(:all, :conditions => ["user_id = ? ", current_user.id],:order => 'created_at DESC')
    @pages, @photographers = paginate_collection @photographers, :page => @params[:page], :per_page => 10
  end

  def show
    @photographer = Photographer.find(params[:id])
    @photographers = Photographer.find(:all, :order => 'read_count DESC', :limit => 6 ,:include =>[:avata])
    @photographer.update_attribute(:read_count,@photographer.read_count + 1)
    @tagged_items = Photographer.tags_count(:limit => 50, :conditions => [" photographers.id = ? ", @photographer.id ])
    @title = "摄影师秀—#{@photographer.name}" 
    render :layout=>'default'
  end

  def new
    @title = "添加摄影师" 
    @photographer = Photographer.new
  end

  def create
    @title = "添加摄影师" 
    @photographer = Photographer.new(params[:photographer])
    @photographer.user_id = current_user.id
    @photographer.province = params[:province]
    @photographer.city = params[:city]
    @photographer.avata = Avata.new(:data => @params[:data])    
    if @photographer.save
      @photographer.tag_with(params[:tags])
      flash[:notice] = "摄影师成功创建"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @photographer = Photographer.find(params[:id])
    self_required(@photographer)
    @title = "编辑摄影师-#{@photographer.name}" 
  end

  def update
    @photographer = Photographer.find(params[:id])
    @photographer.province = params[:province]
    @photographer.city = params[:city]
    @photographer.avata.update_image(@params[:data])
    if @photographer.update_attributes(params[:photographer])
      @photographer.tag_with(params[:tags])
      flash[:notice] = "摄影师资料更新成功"
      redirect_to :action => 'show', :id => @photographer
    else
      render :action => 'edit'
    end
  end

  def destroy
    Photographer.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
 
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each { |id| photographer.find(id.to_i).destroy}
    flash[:notice] = "摄影师删除成功"
    redirect_to :action => 'list'
  end 
  
  def comment
    @photographer = Photographer.find(params[:id])
    if @comment = @photographer.comments.create(params[:comment])
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
    @photographer = Photographer.find(params[:id])
    rank = @photographer.rank + params[:rank].to_i
    if @photographer.update_attributes(:rank_count => @photographer.rank_count + 1,:rank => rank )
      flash[:notice] = "评级成功"
      render(:partial => 'rank') 
    end   
  end
  
  def album
    @photographer = Photographer.find(params[:id])
    @title = "摄影师相册－#{@photographer.name}" 
    @photographer_picture = PhotographerPicture.new
  end

  def city
    @title = "同城摄影师" 
	sql = "SELECT city,COUNT(*) AS count FROM photographers LEFT OUTER JOIN avatas ON avatas.photographer_id = photographers.id " 
	sql << "WHERE city <> '' "
    sql << " GROUP BY city "
	sql << " ORDER BY count DESC" 
	@city = Photographer.find_by_sql(sql)
	@gzphotographers=Photographer.find(:all,:conditions => ['city = ? ','广州'],:order => 'comments_count DESC',:limit => 6,:include => [:avata] )
	@bjphotographers=Photographer.find(:all,:conditions => ['city = ? ','北京'],:order => 'comments_count DESC',:limit => 6 ,:include => [:avata])
	@shphotographers=Photographer.find(:all,:conditions => ['city = ? ','上海'],:order => 'comments_count DESC',:limit => 6,:include => [:avata] )
    @tagged_items = Photographer.tags_count(:limit => 50)  
    render :layout => 'default'
  end
  
  def citysearch
    @title = "同城摄影师" 
	sql = "SELECT city,COUNT(*) AS count FROM photographers " 
	sql << "WHERE city <> '' "
    sql << " GROUP BY city "
	sql << " ORDER BY count DESC" 
	@city = Photographer.find_by_sql(sql)
 	@photographers=Photographer.find(:all,:conditions => ['city = ?',params[:id]],:order => 'comments_count DESC',:include => [:avata])
    @pages, @photographers = paginate_collection @photographers, :page => @params[:page], :per_page => 10
    @tagged_items = Photographer.tags_count(:limit => 50)  
    render :layout => 'default'
  end
  
  def tag
    @photographers = Photographer.find_tagged_with(:conditions => [" tags.name = ? ", params[:id]])
    @pages, @photographers = paginate_collection @photographers, :page => @params[:page], :per_page => 10 
    @tagged_items = Photographer.tags_count(:limit => 50,:conditions=>['photographers.sex = ?',2])    
    render :layout => 'default'
  end
  
  def search
    @title = "摄影师搜索" 
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
	sql = "SELECT photographers.id,province,city,sex,name,rank_count,rank,read_count,comments_count FROM photographers LEFT OUTER JOIN avatas ON avatas.photographer_id = photographers.id " 
	sql << "WHERE avatas.id <> ''"
	sql << "  AND province = '#{params[:province]}'" unless province == 'no'
	sql << "  AND city = '#{params[:city]}'" unless city == 'no'
	sql << "  AND sex = #{params[:sex]}" unless params[:sex].blank?
	sql << " ORDER BY comments_count DESC" 
	@result = Photographer.find_by_sql(sql)
	@pages, @photographers = paginate_collection @result, :page => @params[:page], :per_page => 10
	@new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:limit => 10)
    @tagged_items = Photographer.tags_count(:limit => 50)  
	render :layout => 'default'  
  end
  
  def all
    @title = "全部摄影师" 
    @photographers = Photographer.find(:all, :order => 'created_at DESC',:include => [:avata])
    @pages, @photographers = paginate_collection @photographers, :page => @params[:page], :per_page => 10
    @new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:limit => 10)
    @tagged_items = Photographer.tags_count(:limit => 50)   
    render :layout => 'default'
  end
  
  def add_picture
    @photographer = Photographer.find(params[:id])
    @photographer_picture = PhotographerPicture.new(params[:photographer_picture])
    @photographer_picture.picture = Picture.new(:data => params[:data])
    @photographer.photographer_pictures << @photographer_picture
    @photographer.pictures_count = @photographer.pictures_count + 1
    if @photographer.save
      redirect_to :controller => 'photographers',:action => 'album',:id => @photographer
    end
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
  def destroy_picture
    @photographer = Photographer.find(params[:id])
    @photographer.photographer_pictures[params[:position].to_i - 1].destroy
    @photographer.update_attribute(:pictures_count, @photographer.pictures_count - 1)
    redirect_to :controller => 'photographers',:action => 'album',:id => @photographer
  end
  
  def get_picture
    @picture = PhotographerPicture.find(:first,:conditions=>['photographer_id = ? and position = ?',params[:photographer],params[:position]])
    render :update do |page|
      page.replace_html 'display_image',
        :partial => 'get_picture'
    end
  end  
  
end
