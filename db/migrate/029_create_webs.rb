class CreateWebs < ActiveRecord::Migration
  def self.up
    create_table :webs do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :webs
  end
end
