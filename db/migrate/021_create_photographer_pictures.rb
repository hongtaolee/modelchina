class CreatePhotographerPictures < ActiveRecord::Migration
  def self.up
    create_table :photographer_pictures do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :photographer_pictures
  end
end
