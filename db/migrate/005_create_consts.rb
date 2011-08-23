class CreateConsts < ActiveRecord::Migration
  def self.up
    create_table :consts do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :consts
  end
end
