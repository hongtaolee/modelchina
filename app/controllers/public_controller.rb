class PublicController < ApplicationController
  layout "default" ,:except=>['notice']
  def index
    @title = "首页" 
    @models = Model.find(:all,:conditions=>['height<> ? and status <> ? and pictures_count > ?',0,1,0],:order => 'created_at DESC',:limit=>10,:include=>[:avata])
    @new_groups = Group.find(:all,:order =>'member_count DESC',:limit => 6)
    @new_jobs = Job.find(:all, :conditions => ["state>0"], :order => 'created_at DESC' ,:limit => 6)
#    @photographers = Photographer.find(:all, :order => 'read_count DESC', :limit => 6 ,:include =>[:avata])
    @tagged_items = Model.tags_count(:limit => 50, :conditions => [" taggable_type = ? ", 'Model'],:order=> 'count DESC')
  end
  
  def rank
    @title = "模特排行榜" 
    @models = Model.find(:all,:order => 'read_count DESC',:include => [:avata])
    @pages, @models = paginate_collection @models, :page => @params[:page], :per_page => 10
    @new_groups = Group.find(:all,:order =>'member_count DESC',:limit => 6)
#    @new_jobs = Job.find(:all,:order => 'created_at DESC' ,:limit => 6)
    @tagged_items = Model.tags_count(:limit => 50,:conditions => [" taggable_type = ? ", 'Model'])  
  end
  
  def job
    @title = "模特招聘" 
    @jobs = Job.find(:all, :conditions => ["state>0"], :order => 'created_at DESC')
    @pages, @jobs = paginate_collection @jobs, :page => @params[:page], :per_page => 20
    @new_groups = Group.find(:all,:order =>'created_at DESC' ,:limit => 6)
    @tagged_items = Model.tags_count(:limit => 50, :conditions => [" taggable_type = ? ", 'Model'],:order=> 'count DESC')
  end
  
  def notice
    render :partial=>'notice'      
  end
  
  def search
    
  end

  def ting
    @title = "听歌"
  end
end
