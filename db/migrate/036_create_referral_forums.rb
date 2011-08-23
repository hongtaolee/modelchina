class CreateReferralForums < ActiveRecord::Migration
  def self.up
    create_table :referral_forums, :force => true do |t|
      t.column :name, :string, :default => "", :null => false
      t.column :url, :string, :default => "", :null => false
      t.column :created_at, :datetime, :null => false
    end
    add_index :referral_forums,[:name],:name => "ix_referral_forums_name"
  end

  def self.down
    drop_table :referral_forums
  end
end
