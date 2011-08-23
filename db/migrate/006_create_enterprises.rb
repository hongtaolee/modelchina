class CreateEnterprises < ActiveRecord::Migration
  def self.up
    create_table :enterprises do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :enterprises
  end
end
