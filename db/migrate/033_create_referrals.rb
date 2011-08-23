class CreateReferrals < ActiveRecord::Migration
  def self.up
    create_table :referrals do |t|
      t.column :referral_user_id, :integer, :default => 0, :null => false
      t.column :referral_forum_id, :integer
      t.column :code, :string, :default => "", :null => false
      t.column :created_at, :datetime
    end
    add_index :referrals, [:referral_user_id],:name=>"ix_referrals_user"
  end

  def self.down
    drop_table :referrals
  end
end
