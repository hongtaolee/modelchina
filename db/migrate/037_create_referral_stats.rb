class CreateReferralStats < ActiveRecord::Migration
  def self.up
    create_table :referral_stats do |t|
      t.column :referral_id, :integer
      t.column :today_visit_count, :integer
      t.column :total_visit_count, :integer
      t.column :today_regist_count, :integer
      t.column :total_regist_count, :integer
      t.column :stat_date, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :referral_stats
  end
end
