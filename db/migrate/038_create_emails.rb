class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.column :from, :string
      t.column :to, :string
      t.column :last_send_attempt, :integer, :default => 0
      t.column :mail, :text
      t.column :status, :integer, :limit => 1, :default => 1 # 重发 2 未处理 1 删除 -1  成功 -2 致命错误 -9 
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
      t.column :created_date, :integer
    end
  end

  def self.down
    drop_table :emails
  end
end
