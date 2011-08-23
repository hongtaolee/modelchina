class CreateReferralUsers < ActiveRecord::Migration
  def self.up
    create_table :referral_users do |t|
      t.column :name, :string
      t.column :user_id, :integer
      t.column :email, :string
      t.column :created_at , :datetime
    end
  end

  def self.down
    drop_table :referral_users
  end
end
