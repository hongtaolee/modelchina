class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :members
  end
end
