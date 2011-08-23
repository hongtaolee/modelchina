class NoticesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :only=>['edit','new','create','update','destroy']  
  before_filter :admin_required, :only=>['edit','new','create','update','destroy']
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @notices = Notice.find(:all,:order => 'created_at DESC')
    @pages, @notices = paginate_collection @notices, :page => @params[:page], :per_page => 10
  end

  def show
    @notice = Notice.find(params[:id])
  end

  def new
    @notice = Notice.new
  end

  def create
    @notice = Notice.new(params[:notice])
    if @notice.save
      flash[:notice] = "公告成功创建"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @notice = Notice.find(params[:id])
  end

  def update
    @notice = Notice.find(params[:id])
    if @notice.update_attributes(params[:notice])
      flash[:notice] = "公告成功创建"
      redirect_to :action => 'show', :id => @notice
    else
      render :action => 'edit'
    end
  end

  def destroy
    Notice.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
