class CreatePhotographers < ActiveRecord::Migration
  def self.up
    create_table :photographers do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :photographers
  end
end
