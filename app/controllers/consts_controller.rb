class ConstsController < ApplicationController
  layout "admin"
  before_filter :login_required, :only=>['edit','new','create','update','destroy','delete']  
  before_filter :admin_required, :only=>['edit','new','create','update','destroy','delete']
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @consts = Const.find(:all,:order=>'table_name,field_name')
    @pages, @consts = paginate_collection @consts, :page => @params[:page], :per_page => 20
  end

  def show
    @const = Const.find(params[:id])
  end

  def new
    @const = Const.new
  end

  def create
    @const = Const.new(params[:const])
    if @const.save
      flash[:notice] = "常量成功创建"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @const = Const.find(params[:id])
  end

  def update
    @const = Const.find(params[:id])
    if @const.update_attributes(params[:const])
      flash[:notice] = "常量已经成功删除"
      redirect_to :action => 'show', :id => @const
    else
      render :action => 'edit'
    end
  end

  def destroy
    Const.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each { |id| Const.find(id.to_i).destroy}
    flash[:notice] = "消息成功删除"
    redirect_to :action => 'list'
  end
end
