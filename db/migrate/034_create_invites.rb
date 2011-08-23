class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites, :force => true do |t|
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :code, :string, :default => "", :null => false
      t.column :created_at, :datetime
    end
    add_index :invites, ["user_id"],:name=>"ix_invites_user"
  end

  def self.down
    drop_table :invites
  end
end
