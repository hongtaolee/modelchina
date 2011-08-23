class CreateTrades < ActiveRecord::Migration
  def self.up
    create_table :trades do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :trades
  end
end
