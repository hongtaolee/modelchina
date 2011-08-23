class FavsController < ApplicationController
  layout "admin"
  before_filter :login_required, :only=>['list', 'edit', 'new', 'create','update','destroy']
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @favs = Fav.find(:all,:conditions=>['user_id = ? ',current_user.id],:order => 'created_at DESC')
    @pages, @favs = paginate_collection @favs, :page => @params[:page], :per_page => 10
  end

  def show
    @fav = Fav.find(params[:id])
  end

  def new
    @agency = User.find(params[:id])
    @fav=Fav.new
    @fav.user_id = current_user.id
    @fav.friend_id = @agency.id
    if @fav.save
      flash[:notice] = "#{@agency.name} 成功添加为好友"
      render :update do |page|
        page.replace_html 'is_friend',:partial=>'friend'       
      end
    else
      flash[:notice] = "Sorry， 添加好友失败"
      redirect_to_stored
    end
  end

  def create
    @fav = Fav.new(params[:fav])
    if @fav.save
      flash[:notice] = "成功添加好友"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @fav = Fav.find(params[:id])
  end

  def update
    @fav = Fav.find(params[:id])
    if self_required(@job)
      if @fav.update_attributes(params[:fav])
        flash[:notice] = "好友删除成功"
        redirect_to :action => 'show', :id => @fav
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    Fav.find(params[:id]).destroy
    if self_required(@job)
      redirect_to :action => 'list'
    end
  end
  
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each do |id|
      @notice = Notice.find(id.to_i)
      if self_required(@notice)
        @notice.destroy
      else
        @error = 1
      end
    end
    unless @error ==  1
      flash[:notice] = "好友删除成功"
      redirect_to :action => 'list'
    end
  end
end
