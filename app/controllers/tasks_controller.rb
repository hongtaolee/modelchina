class TasksController < ApplicationController
  layout "default"
  before_filter :login_required
  before_filter :admin_required
  def index
    @tasks = Task.find(:all, :conditions=>['user_id = ? and plan_time > ?',@current_user.id,Date.today])
    @projects = Project.find(:all, :conditions=>['user_id = ? ',@current_user.id],:order=>'created_at DESC')
    @wisdoms = Wisdom.find(:all)
  end
  
  def new
  
  end
  
  def edit
  
  end
end
