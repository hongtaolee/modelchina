class CreateBlockedIps < ActiveRecord::Migration
  def self.up
    create_table :blocked_ips do |t|
      t.column :ip, :string
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    add_index :blocked_ip, :ip, :name => 'ix_blocked_ips_ip', :unique => true
  end

  def self.down
    drop_table :blocked_ips
  end
end
