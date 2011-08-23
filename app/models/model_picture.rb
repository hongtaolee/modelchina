class ModelPicture < ActiveRecord::Base
  belongs_to :picture
  belongs_to :model
  acts_as_list :scope => :model_id
end
