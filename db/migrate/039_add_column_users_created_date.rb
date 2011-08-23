class AddColumnUsersCreatedDate < ActiveRecord::Migration
  class User < ActiveRecord::Base;  end
  def self.up
    add_column :users, :created_date, :integer
    add_index :users, :created_date, :name => 'ix_users_created_date'

    User.find(:all).each do |u|
      u.update_attribute(:created_date, u.created_at.strftime("%Y%m%d").to_i)
    end    
  end

  def self.down
    remove_index :users, :name => 'ix_users_created_date' 
    remove_column :users, :created_date     
  end
end
