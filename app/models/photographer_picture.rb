class PhotographerPicture < ActiveRecord::Base
  belongs_to :picture
  belongs_to :photographer
  acts_as_list :scope => :photographer_id
end
