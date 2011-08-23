class LinksController < ApplicationController
  layout 'admin'
  before_filter :login_required, :only=>['edit','update','destroy']
  before_filter :admin_required, :only=>['edit','update','destroy']
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @link_pages, @links = paginate :links, :per_page => 10
  end

  def new
    @link = Link.new
    render :layout => 'default'
  end

  def show
    @link = Link.find(params[:id])
    @link.update_attribute(:in_count, @link.in_count + 1)
    redirect_to :controller=>'public'    
  end
  
  def ok
    @link = Link.find(params[:id])
    render :layout => 'web'  
  end
  
  def create
    @link = Link.new(params[:link])
    if @link.save
      redirect_to :action => 'ok',:id => @link
    else
      render :action => 'new'
    end
  end

  def edit
    @link = Link.find(params[:id])
  end

  def update
    @link = Link.find(params[:id])
    if @link.update_attributes(params[:link])
      flash[:notice] = 'Link was successfully updated.'
      redirect_to :action => 'show', :id => @link
    else
      render :action => 'edit'
    end
  end

  def destroy
    Link.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
