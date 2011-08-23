class CreateOldImages < ActiveRecord::Migration
  def self.up
    create_table :old_images do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :old_images
  end
end
