class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :pictures
  end
end
