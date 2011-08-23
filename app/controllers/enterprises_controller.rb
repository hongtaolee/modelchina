class EnterprisesController < ApplicationController
  layout "default", :except=>['edit','update']
  before_filter :login_required, :only=>['edit','update']
  
  def list
    @enterprises = Enterprise.find(:all,:conditions=>['status = ? and name <> ?', '8',''],:order =>'number')
    @pages, @enterprises = paginate_collection @enterprises, :page => @params[:page], :per_page => 10
    @new_enterprises = Enterprise.find(:all,:conditions=>[' name <> ?',''],:order => 'created_at DESC',:limit => 6)
    @new_groups = Group.find(:all,:order =>'member_count DESC' ,:limit => 6)
    @tagged_items = Model.tags_count(:limit => 50)  
  end
  def edit
    @enterprise = Enterprise.find_by_user_id(session[:user_id])
    @title = "编辑企业信息－#{@enterprise.name}"
    render :layout=>'admin'
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end

  def update
    @enterprise = Enterprise.find_by_user_id(session[:user_id])
    if @enterprise.update_attributes(params[:enterprise])
      flash[:notice] = "企业资料更新成功"
      redirect_to :controller => 'user',:action => 'show'
    else
      redirect_to :action => 'edit'
    end
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
  
  def show
    @enterprise = Enterprise.find(params[:id])
    @title = "企业－#{@enterprise.name}"
    @models = Model.find(:all,:conditions=>['user_id = ?',@enterprise.user_id],:limit => 6)
    @jobs = Job.find(:all,:conditions=>['user_id = ?',@enterprise.user_id],:limit => 6)
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
  
  def model
    @enterprise = Enterprise.find(params[:id])
    @title = "企业－#{@enterprise.name}-模特列表"
    @models = Model.find(:all,:conditions=>['user_id = ?',@enterprise.user_id])
    @pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 20
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
  
  def job
    @enterprise = Enterprise.find(params[:id])
    @title = "企业－#{@enterprise.name}-招聘信息"
    @jobs = Job.find(:all,:conditions=>['user_id = ?',@enterprise.user_id])
    @pages, @jobs = paginate_collection @jobs, :page => @params[:page], :per_page => 20
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
end
