class AddColumnModelsUpdatedAt < ActiveRecord::Migration
  class Model < ActiveRecord::Base;  end
  def self.up
    add_column :models, :updated_at, :datetime

    Model.find(:all).each do |m|
      m.update_attribute(:updated_at, m.created_at)
    end    
  end

  def self.down
    remove_column :models, :updated_at    
  end
end
