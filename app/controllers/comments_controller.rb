class CommentsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :only=>['list','destroy', 'proof', 'destroy_user']
  before_filter :admin_required, :only=>['list', 'destroy', 'proof', 'destroy_user']

  def list
    comments = Comment.find(:all, :order => "id desc")
    @total_size = comments.size
    @comment_pages, @comments = paginate_collection comments, :page => @params[:page],  :per_page => 500
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    render :update do |page|
      page.remove "comment_#{@comment.id}"
    end
  end
  
  def proof
    @comment = Comment.find(params[:id])
    @comment.status = 1
    @comment.save(false)
    render :update do |page|
      page.replace_html "comment_#{@comment.id}", :partial => "comment", :locals => {:comment => @comment}
    end
  end
  
  def destroy_user
    @comments = Comment.find(:all, :conditions => ["user_id=?", params[:user_id]])
    @comments.each do |comment|
      comment.destroy
    end
    
    render :update do |page|
      page.call 'location.reload'
    end    
  end
    
end
