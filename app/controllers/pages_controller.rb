# require 'hpricot'
# require 'open-uri'
class PagesController < ApplicationController
  layout 'admin',:except=>['show','list']
  before_filter :login_required, :only=>['join','tagging','new', 'create','update','destroy','edit']
  before_filter :admin_required, :only=>['new','create','update','destroy','edit','tagging']

  def index
    list
    render :action => 'list'
  end
  def confirm_destroy
    redirect_to :controller=>'public'
  end
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def data
#    @http="http://www.rayli.com.cn"
#    @doc = Hpricot(URI.parse("http://www.rayli.com.cn/region/C0008004.html").read) 
    @posts = Post.find(:all)
    for post in @posts
#      unless post.picture.blank?
#        picture = post.picture.gsub(/http:\/\/www.model-china.cn\/images\/thumbs\/\d*?\//,'http://www.model-china.cn/old_images/show/')
#        picture = picture.gsub('_s.jpg','.jpg')
#        picture = picture.gsub('_m.jpg','.jpg')
#        post.update_attribute(:picture,picture)
#         content = post.content
#         parse_picture(post.picture).each do |picture|
#            content = content + "<div class='post_picture'><img src='#{picture}'></div>"
#         end
#         post.update_attribute(:content,content)
#      end
        post.update_attribute(:user_id,post.user_id + 100)
    end
  
  
  end
  
  def digg
    @page = Page.find(params[:id])
    if params[:o] == '1'
       Page.update(@page.id,:digg => @page.digg + 1)
       render :update do |page|
        page.replace_html "digg_count_#{@page.id}" , "#{@page.digg + 1}"
       end 
    else
      i = 1
      while !@old_page = Page.find_by_number(@page.number + i)
        i = i + 1
      end
      @page.update_attributes(:number => @page.number + i,:digg => @page.digg + 1)
      Page.update(@old_page.id,:number => @old_page.number - i)
      @o = params[:o].to_i - 1
      render :update do |page|
        page.remove "page_#{@page.id}"
        page.insert_html :before, "page_#{@old_page.id}" ,:partial => "digg"
        page.visual_effect :highlight, "page_#{@page.id}",:duration => 3
      end      
    end
  end
  
  def tagging
    @page = Page.find(params[:id])
    @page.tag_with(params[:tag_list])
    if @page.save
      @tagged_items = Page.tags_count(:conditions => ['pages.id = ?',@page.id])
      render :update do |page|
        page.hide "tag_form"
        page.replace_html "tag_cloudy",:partial => "tag"
        page.toggle "tag_cloudy"
        page.visual_effect :highlight, "tag_cloudy",:duration => 3
      end
    end
  end
  
  def list
    @title = "行业资讯"
    @pages = Page.find(:all, :order => 'number DESC')
	sql = "SELECT category,COUNT(*) AS count FROM pages " 
	sql << "WHERE category <> '' "
    sql << " GROUP BY category "
	sql << " ORDER BY count DESC" 
	@categories = Page.find_by_sql(sql)
    @tagged_items = Page.tags_count(:limit => 50,:conditions => ['pages.id <> ? ',nil])
    @pages, @webs = paginate_collection @pages, :page => @params[:page], :per_page => 15
    render :layout => 'default'
  end

  def category
    @title = "行业资讯-#{params[:id]}"
    @pages = Page.find(:all, :conditions=>['category = ? ',params[:id]],:order => 'number DESC')
	sql = "SELECT category,COUNT(*) AS count FROM pages " 
	sql << "WHERE category <> '' "
    sql << " GROUP BY category "
	sql << " ORDER BY count DESC" 
	@categories = Page.find_by_sql(sql)
    @tagged_items = Page.tags_count(:limit => 50,:conditions => ['pages.id <> ? ',nil])
    @pages, @webs = paginate_collection @pages, :page => @params[:page], :per_page => 15
    render :layout => 'default'
  end
  
  def tag
    @title = "行业资讯-#{params[:id]}"
    @pages = Page.find_tagged_with(:conditions=>["tags.name = ?",params[:id]])
	sql = "SELECT category,COUNT(*) AS count FROM pages " 
	sql << "WHERE category <> '' "
    sql << " GROUP BY category "
	sql << " ORDER BY count DESC" 
	@categories = Page.find_by_sql(sql)
    @tagged_items = Page.tags_count(:limit => 50,:conditions => ['pages.id <> ? ',nil])
    @pages, @webs = paginate_collection @pages, :page => @params[:page], :per_page => 15
    render :layout => 'default'
  end
  
  def show
    @page = Page.find(params[:id])
    @title = @page.title
    Page.update(@page.id, :count => @page.count + 1 )
    @tagged_items = Page.tags_count(:limit => 50, :conditions => [" pages.id = ? ", @page.id ])
    render :layout => 'default'
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = 'Page was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = 'Page was successfully updated.'
      redirect_to :action => 'show', :id => @page
    else
      render :action => 'edit'
    end
  end

  def destroy
    Page.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  private
	def parse_picture(picture)
    picture_names = []

    # first, pull out the quoted tags
    picture.gsub!(/\"(.*?)\"\s*/ ) { picture_names << $1; "" }

    # then, replace all commas with a space
    picture.gsub!(/,/, " ")

    # then, get whatever's left
    picture_names.concat picture.split(/\s/)

    # strip whitespace from the names
    picture_names = picture_names.map { |t| t.strip }

    # delete any blank tag names
    picture_names = picture_names.delete_if { |t| t.empty? }
    
    return picture_names
	
	end
end
