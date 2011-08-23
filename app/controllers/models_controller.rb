class ModelsController < ApplicationController
  layout "admin", :except => [:show,:comment,:girl,:boy,:city,:foreign,:all,:search,:tag,:tags]
  before_filter :login_required, :only=>['add_picture','destroy_picture','list', 'edit', 'new', 'create','update','destroy','comment','album']
  def index
    redirect_to :action => 'search'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def tags
    @tagged_items = Model.tags_count(:limit => 50,:conditions => [" taggable_type = ? ", 'Model'])
    render :layout => 'default'
  end
  
  def list
    @title = "模特列表" 
    @models = Model.find(:all, :conditions => ["user_id = ? ", current_user.id],:order => 'created_at DESC')
    @pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
  end

  def show
    @model = Model.find(params[:id])
    @models = Model.find(:all,:conditions=>['height>? and status <> ? and pictures_count > ?',100,1,0],:order => 'RAND()',:limit=>6,:include=>[:avata])
#    @models = Model.find(:all, :order => 'read_count DESC', :limit => 6 ,:include =>[:avata])
    @model.update_attribute(:read_count,@model.read_count + 1)
    @tagged_items = Model.tags_count(:limit => 50, :conditions => [" taggable_type = ? and models.id = ? ", 'Model',@model.id ])
    @title = "模特秀—#{@model.name}" 
    render :layout=>'default'
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public'   
  end

  def profile
    @model = Model.find(params[:id])
    @models = Model.find(:all, :order => 'read_count DESC', :limit => 6 ,:include =>[:avata])
    @model.update_attribute(:read_count,@model.read_count + 1)
    @tagged_items = Model.tags_count(:limit => 50, :conditions => [" taggable_type = ? and models.id = ? ", 'Model',@model.id ])
    @title = "模特—#{@model.name}的个人资料" 
    render :layout=>'default'
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public'   
  end
  
  def new
    @title = "添加模特" 
    @model = Model.new
  end

  def create
    @title = "添加模特" 
    @model = Model.new(params[:model])
    @model.user_id = current_user.id
    @model.province = params[:province]
    @model.city = params[:city]
    @model.avata = Avata.new(:data => @params[:data])    
    if @model.save
      @model.tag_with(params[:tags])
      flash[:notice] = "新模特成功添加"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @model = Model.find(params[:id])
    self_required(@model)
    @title = "编辑模特-#{@model.name}" 
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public' 
  end

  def update
    @model = Model.find(params[:id])
    @model.province = params[:province]
    @model.city = params[:city]
    @model.avata.update_image(@params[:data])
    if @model.update_attributes(params[:model])
      @model.tag_with(params[:tags])
      flash[:notice] = "模特资料更新成功"
      redirect_to :action => 'show', :id => @model
    else
      render :action => 'edit'
    end
  end

  def destroy
    Model.find(params[:id]).destroy
    redirect_to :action => 'list'
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public' 
  end
 
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each { |id| Model.find(id.to_i).destroy}
    flash[:notice] = "该模特成功删除"
    redirect_to :action => 'list'
  end 
  
  def comment
    @model = Model.find(params[:id])
    if @comment = @model.comments.create(params[:comment])
      render :update do |page|
        page.insert_html :bottom, 'comments', :partial=>'comment',:object => @comment
        page.visual_effect :blind_down, "comment_item_#{@comment.id}", :duration => 1
        page.visual_effect :highlight, "comment_item_#{@comment.id}", :duration => 3
      end
#    else
#      flash[:notice] =  _('sorry,failure……')
#      redirect_to_stored
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
    @model = Model.find(params[:id])
    rank = @model.rank + params[:rank].to_i
    if @model.update_attributes(:rank_count => @model.rank_count + 1,:rank => rank )
      flash[:notice] = "评级成功"
      render(:partial => 'rank') 
    end   
  end
  
  def album
    @model = Model.find(params[:id])
    @title = "模特相册－#{@model.name}" 
    @model_picture = ModelPicture.new
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public' 
  end

  def city
    @title = "同城模特" 
	sql = "SELECT city,COUNT(*) AS count FROM models LEFT OUTER JOIN avatas ON avatas.model_id = models.id " 
	sql << "WHERE city <> '' "
    sql << " GROUP BY city "
	sql << " ORDER BY count DESC" 
	@city = Model.find_by_sql(sql)
	@gzmodels=Model.find(:all,:conditions => ['city = ? ','广州'],:order => 'read_count DESC',:limit => 6,:include => [:avata] )
	@bjmodels=Model.find(:all,:conditions => ['city = ? ','北京'],:order => 'read_count DESC',:limit => 6 ,:include => [:avata])
	@shmodels=Model.find(:all,:conditions => ['city = ? ','上海'],:order => 'read_count DESC',:limit => 6,:include => [:avata] )
	@new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 10)
    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:limit => 10)
    @tagged_items = Model.tags_count(:limit => 50,:conditions=>['taggable_type = ?','Model'])  
    render :layout => 'default'
  end
  
  def citysearch
    @title = "同城模特" 
	sql = "SELECT city,COUNT(*) AS count FROM models " 
	sql << "WHERE city <> '' "
    sql << " GROUP BY city "
	sql << " ORDER BY count DESC" 
	@city = Model.find_by_sql(sql)
 	@models=Model.find(:all,:conditions => ['city = ?',params[:id]],:order => 'read_count DESC',:include => [:avata])
    @pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
    @tagged_items = Model.tags_count(:limit => 50,:conditions=>['taggable_type = ?','Model'])  
    render :layout => 'default'
  end
  
  def tag
    @models = Model.find_tagged_with(:conditions => [" tags.name = ? ", params[:id]])
    @pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10 
    @tagged_items = Model.tags_count(:limit => 50,:conditions=>['models.sex = ? and taggable_type = ? ',2,'Model'])    
    render :layout => 'default'
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public' 
  end
  
  def boy
    @title = "男模特" 
 	sql = "SELECT models.id,name,province,city,height,chest,waist,hips,rank,rank_count,read_count,comments_count  FROM models LEFT OUTER JOIN avatas ON avatas.model_id = models.id " 
	sql << "WHERE sex = '2' "
	sql << " ORDER BY read_count DESC" 
	@models = Model.find_by_sql(sql)
	@new_models = Model.find(:all,:conditions=>['sex = ?',2],:order=>'created_at DESC',:limit => 6,:include=>[:avata])
	@pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
    @tagged_items = Model.tags_count(:limit => 50,:conditions=>['models.sex = ? and taggable_type = ?',2,'Model'])    
    render :layout => 'default'
  end
  
  def girl
    @title = "女模特" 
 	sql = "SELECT models.id,name,province,city,height,chest,waist,hips,rank,rank_count,read_count,comments_count  FROM models LEFT OUTER JOIN avatas ON avatas.model_id = models.id " 
	sql << "WHERE sex = '1' "
	sql << " ORDER BY read_count DESC" 
	@models = Model.find_by_sql(sql)
	@new_models = Model.find(:all,:conditions=>['sex = ?',1],:order=>'created_at DESC',:limit => 6,:include=>[:avata])
	@pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
    @tagged_items = Model.tags_count(:limit => 50,:conditions=>['models.sex = ? and taggable_type = ?',1,'Model'])     
    render :layout => 'default'
  end
  
  def foreign
    @title = "外籍模特" 
 	sql = "SELECT models.id,name,province,city,height,chest,waist,hips,rank,rank_count,read_count,comments_count  FROM models LEFT OUTER JOIN avatas ON avatas.model_id = models.id " 
	sql << "WHERE country <> 'CN' "
	sql << " ORDER BY read_count DESC" 
	@models = Model.find_by_sql(sql)
	@new_models = Model.find(:all,:conditions=>['country <> ?','CN'],:order=>'created_at DESC',:limit => 6,:include=>[:avata])
	@pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
    @tagged_items = Model.tags_count(:limit => 50,:conditions=>['models.country <> ? and taggable_type = ?','china','Model'])      
    render :layout => 'default'
  end
  
  def search
    @title = "模特搜索" 
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
    case params[:category1]
      when "china:girl"
        sex = "1"
        foreign ="no"
        china = "yes"     
      when "china:boy"
        sex = "2"
        foreign ="no"
        china = "yes"      
      when "foreign:girl"
        sex = "1"
        foreign ="yes"
        china = "no"      
      when "foreign:boy"
        sex = "2"
        foreign ="yes"
        china = "no"
      else
        sex = "0"
        foreign ="no"
        china = "no"
    end
       
	sql = "SELECT models.id,name,province,city,height,chest,waist,hips,rank,rank_count,read_count,comments_count FROM models LEFT OUTER JOIN avatas ON avatas.model_id = models.id " 
	sql << "WHERE status <> '1' "
	sql << "  AND province = '#{params[:province]}'" unless province == 'no'
	sql << "  AND city = '#{params[:city]}'" unless city == 'no'
	sql << "  AND sex = #{sex}" unless sex == '0'
	sql << "  AND country = 'CN'" unless china=='no'
	sql << "  AND country <> 'CN'" unless foreign=='no'
	sql << "  AND category like '%#{params[:category2]}%'" unless params[:category2] == '全部' || params[:category2].blank?
	sql << "  AND height >= '#{params[:minheight]}'" unless params[:minheight] == '0' || params[:minheight].blank?
	sql << "  AND height <= '#{params[:maxheight]}'" unless params[:maxheight] == '0' || params[:maxheight].blank?
	sql << "  AND weight >= '#{params[:minweight]}'" unless params[:minweight] == '0' || params[:minweight].blank?
	sql << "  AND weight <= '#{params[:maxweight]}'" unless params[:maxweight] == '0' || params[:maxweight].blank?
	sql << "  AND chest >= '#{params[:minchest]}'" unless params[:minchest] == '0' || params[:minchest].blank?
	sql << "  AND chest <= '#{params[:maxchest]}'" unless params[:maxchest] == '0' || params[:maxchest].blank?
	sql << "  AND waist >= '#{params[:minwaist]}'" unless params[:minwaist] == '0' || params[:minwaist].blank?
	sql << "  AND waist <= '#{params[:maxwaist]}'" unless params[:maxwaist] == '0' || params[:maxwaist].blank?
	sql << "  AND hips >= '#{params[:minhips]}'" unless params[:minhips] == '0' || params[:minhips].blank?
	sql << "  AND hips <= '#{params[:maxhips]}'" unless params[:maxhips] == '0' || params[:maxhips].blank?
	sql << "  AND shoes >= '#{params[:minshoes]}'" unless params[:minshoes] == '0' || params[:minshoes].blank?
	sql << "  AND shoes <= '#{params[:maxshoes]}'" unless params[:maxshoes] == '0' || params[:maxshoes].blank?
	sql << " ORDER BY read_count DESC" 
	@result = Model.find_by_sql(sql)
	@pages, @models = paginate_collection @result, :page => @params[:page], :per_page => 10
    @tagged_items = Model.tags_count(:limit => 50,:conditons=>['taggable_type = ?','Model'])  
	render :layout => 'default'  
  end
  
  def all
    @title = "全部模特" 
    @models = Model.find(:all,:conditions => ['status <> ? ',1], :order => 'created_at DESC',:include => [:avata])
    @pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
    @tagged_items = Model.tags_count(:limit => 50,:conditons=>['taggable_type = ?','Model'])   
    render :layout => 'default'
  end
  
  def add_picture
    @model = Model.find(params[:id])
    @model_picture = ModelPicture.new(params[:model_picture])
    @model_picture.picture = Picture.new(:data => params[:data])
    @model.model_pictures << @model_picture
    @model.pictures_count = @model.pictures_count + 1
    if @model.save
      redirect_to :controller => 'models',:action => 'album',:id => @model
    end
#  rescue
#    flash[:notice] = 'Sorry,您访问的页面不存在'
#    redirect_to :controller=>'public' 
  end
  def destroy_picture
    @model = Model.find(params[:id])
    @model.model_pictures[params[:position].to_i - 1].destroy
    @model.update_attribute(:pictures_count, @model.pictures_count - 1)
    redirect_to :controller => 'models',:action => 'album',:id => @model
  end
  
  def get_picture
    @picture = ModelPicture.find(:first,:conditions=>['model_id = ? and position = ?',params[:model],params[:position]])
    render :update do |page|
      page.replace_html 'display_image',
        :partial => 'get_picture'
    end
  end
  
  def group
    @model = Model.find(params[:id])
    if Group.find_by_model_id(params[:id])
      @group = Group.find_by_model_id(params[:id])
    else
      @group = Group.new(:model_id => params[:id],
                   :name => "#{@model.name}的Fans圈",
                   :description => "欢迎光临#{@model.name}的Fans圈.",
                   :admin => @model.user.id)
      if @group.save
        @member = Member.new
        @member.user_id = @model.user.id
        @member.group_id = @group.id
        @member.save
      end
    end
    redirect_to :controller=>'groups',:action=>'show',:id=>@group
  end
  
  def tagging
    @model = Model.find(params[:id])
    @model.tag_with(params[:tag_list])
    if @model.save
      @tagged_items = Model.tags_count(:conditions => ['models.id = ?',@model.id])
      render :update do |page|
        page.hide "tag_form"
        page.replace_html "tag_cloudy",:partial => "tag"
        page.toggle "tag_cloudy"
        page.visual_effect :highlight, "tag_cloudy",:duration => 3
      end
    end
  end
    
end
