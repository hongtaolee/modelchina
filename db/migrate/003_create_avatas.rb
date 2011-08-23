class CreateAvatas < ActiveRecord::Migration
  def self.up
    create_table :avatas do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :avatas
  end
end
