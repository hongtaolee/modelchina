class AddColumnCommentsStatus < ActiveRecord::Migration
  class Comment < ActiveRecord::Base;  end
  def self.up
    add_column :comments, :status, :integer, :default => 0

    Comment.find(:all).each do |m|
      m.update_attribute(:status, 1)
    end
        
    add_column :jobs, :state, :integer, :default => 0
    Job.find(:all).each do |job|
      job.update_attribute(:state, 1)
    end
  end

  def self.down
    remove_column :comments, :status
    remove_column :jobs, :status    
  end
end