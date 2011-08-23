class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :super_images, :force => true do |t|
      t.column :data, :binary, :size => 10000000, :null => false
      t.column :created_at, :datetime
    end
    execute "ALTER TABLE `super_images` MODIFY `data` MEDIUMBLOB"
  end

  def self.down
    drop_table :super_images
  end
end
