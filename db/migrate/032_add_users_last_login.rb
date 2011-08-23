class AddUsersLastLogin < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login, :datetime
    add_column :users, :last_ip, :string
    add_column :users, :login_times, :integer, :default => 1
    add_column :users, :source, :integer
    add_column :users, :source_detail, :string
    add_column :users, :status, :integer, :limit => 1, :default => 1
    add_column :users, :privacy, :boolean, :default => false
    add_column :users, :has_avatar, :boolean, :default => false
  end

  def self.down
  end
end
