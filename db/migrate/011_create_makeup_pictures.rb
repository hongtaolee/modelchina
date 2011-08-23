class CreateMakeupPictures < ActiveRecord::Migration
  def self.up
    create_table :makeup_pictures do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :makeup_pictures
  end
end
