class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :comments
  end
end
