class CreatePageContents < ActiveRecord::Migration
  def self.up
    create_table :page_contents do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :page_contents
  end
end
