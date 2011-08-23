class CreateLoginLogs < ActiveRecord::Migration
  def self.up
    create_table :login_logs do |t|
      t.column :user_id, :integer
      t.column :session_id, :string
      t.column :remote_ip, :string
      t.column :owner_type, :string  # referral_id, invite_id
      t.column :owner_id, :integer
      t.column :created_date, :integer
      t.column :created_at, :datetime
    end
    add_index :login_logs, :user_id, :name => 'ix_login_logs_user'
    add_index :login_logs, [:owner_type, :owner_id], :name => 'ix_login_logs_owner'
    add_index :login_logs, :created_date, :name => 'ix_login_logs_created_date'
  end

  def self.down
    drop_table :login_logs
  end
end
