class CreateMakeups < ActiveRecord::Migration
  def self.up
    create_table :makeups do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :makeups
  end
end
