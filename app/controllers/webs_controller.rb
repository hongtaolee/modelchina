class WebsController < ApplicationController
  layout "web", :except=>['list','new','edit']
  before_filter :login_required, :only=>['list', 'edit', 'new', 'create','update','destroy']
  before_filter :admin_required, :only=>['edit','new','create','update','destroy']
  caches_page :show
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title = "网页列表"
    @webs = Web.find(:all,:order => 'created_at DESC')
    @pages, @webs = paginate_collection @webs, :page => @params[:page], :per_page => 10
    render :layout=>'admin'
  end

  def show
    # 历史遗留问题，流量转换
    unless @web = Web.find_by_url(params[:id])
      redirect_to :controller=>'public',:action=>'index'
    end
    @title = @web.title
  end
  
  def confirm_destroy
    redirect_to :controller=>'public',:action=>'index'
  end
  
  def new
    @title = "添加新网页"
    @web = Web.new
    render :layout=>'admin'
  end

  def create
    @web = Web.new(params[:web])
    if @web.save
      flash[:notice] = "网页成功创建"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @web = Web.find(params[:id])
    @title = "编辑网页－#{@web.title}"
    render :layout=>'admin'
  end

  def update
    @web = Web.find(params[:id])
    if @web.update_attributes(params[:web])
      flash[:notice] = "网页更新成功"
      redirect_to :action => 'show', :id => @web.url
    else
      render :action => 'edit'
    end
  end

  def destroy
    Web.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each { |id| Web.find(id.to_i).destroy}
    flash[:notice] = "网页成功删除"
    redirect_to :action => 'list'
  end
  
end
