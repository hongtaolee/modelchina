class CreateFavs < ActiveRecord::Migration
  def self.up
    create_table :favs do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :favs
  end
end
