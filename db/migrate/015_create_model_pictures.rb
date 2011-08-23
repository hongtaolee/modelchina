class CreateModelPictures < ActiveRecord::Migration
  def self.up
    create_table :model_pictures do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :model_pictures
  end
end
