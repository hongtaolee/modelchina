class JobsController < ApplicationController
  layout "admin" ,:except=>['show']
  before_filter :login_required, :only=>['proof_list', 'proof', 'proof_destroy', 'proof_destroy_user', 'list', 'edit', 'new', 'create','update','destroy']
  before_filter :admin_required, :only=>['proof_list', 'proof', 'proof_destroy', 'proof_destroy_user']  
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)

  def proof_list
    jobs = Job.find(:all, :order => "id desc")
    @total_size = jobs.size
    @job_pages, @jobs = paginate_collection jobs, :page => @params[:page], :per_page => 500    
  end
  
  def proof
    @job = Job.find(params[:id])
    @job.state = 1
    @job.save(false)
    render :update do |page|
      page.replace_html "job_#{@job.id}", :partial => "job", :locals => {:job => @job}
    end    
  end
  
  def proof_destroy
    @job = Job.find(params[:id])
    @job.destroy
    render :update do |page|
      page.remove "job_#{@job.id}"
    end    
  end
  
  def proof_destroy_user
    @jobs = Job.find(:all, :conditions => ["user_id=?", params[:user_id].to_i])
    @jobs.each do |job|
      job.destroy
    end
    
    render :update do |page|
      page.call 'location.reload'
    end    
  end
    
  def list
    @title = "工作列表"
    @jobs = Job.find(:all, :conditions => ["user_id = ?", current_user.id],:order => 'created_at DESC')
    @pages, @jobs = paginate_collection @jobs, :page => @params[:page], :per_page => 10
  end

  def show
    @job = Job.find(params[:id])
    @title = "模特招聘－#{@job.work}"
    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:conditions=>['id <> ? and user_id = ?',@job.id,@job.user_id],:limit => 10)
    render :layout=>'default'
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end

  def new
    @title = "发布新的招聘信息"
    @job = Job.new
  end

  def create
    @job = Job.new(params[:job])
    @job.user_id = current_user.id
    if @job.save
      flash[:notice] = "新招聘信息成功发布"
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @job = Job.find(params[:id])
    self_required(@job)
    @title = "编辑招聘信息－#{@job.work}"
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end

  def update
    @job = Job.find(params[:id])
    if self_required(@job)
      if @job.update_attributes(params[:job])
        flash[:notice] = "招聘信息更新成功"
        redirect_to :action => 'show', :id => @job
      else
        render :action => 'edit'
      end
    end
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end

  def destroy
    @job = Job.find(params[:id])
    if self_required(@job)
      @job.destroy
      redirect_to :action => 'list'
    end
  rescue
    flash[:notice] = 'Sorry,您访问的页面不存在'
    redirect_to :controller=>'public' 
  end
  
  def delete
    checked = params[:check_all]
    check = []
    # then, replace all commas with a space
    checked.gsub!(/check_/, "")
    checked.gsub!(/,/, " ")
    check.concat checked.split(/\s/)
    check.each do |id|
      @job = Job.find(id.to_i)
      if self_required(@job)
        @job.destroy
      else
        @error = 1
      end
    end
    unless @error == 1
      flash[:notice] = "Sorry，失败了"
      redirect_to :action => 'list'
    end
  end
  
  def add
    @job = Job.find(params[:id])
    @trade=Trade.new
    @trade.user_id = current_user.id
    @trade.job_id = @job.id
    if @trade.save
      @job.update_attribute(:user_count,@job.user_count+1)
      flash[:notice] = "OK，操作成功！"
    else
      flash[:notice] = "Sorry，失败了"
    end  
    redirect_to :controller=>'jobs',:action => 'show',:id=>@job.id
  end
end
