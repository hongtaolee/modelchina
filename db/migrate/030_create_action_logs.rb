class CreateActionLogs < ActiveRecord::Migration
  def self.up
    create_table :action_logs do |t|
      t.column :user_id, :integer
      t.column :session_id, :string
      t.column :request_uri, :string
      t.column :remote_ip, :string
      t.column :action_uri, :string
      t.column :created_date, :integer
      t.column :created_at, :datetime
    end
    add_index :action_logs, :user_id, :name => 'ix_action_logs_user'
    add_index :action_logs, :created_date, :name => 'ix_action_logs_created_date'
  end

  def self.down
    drop_table :action_logs
  end
end
