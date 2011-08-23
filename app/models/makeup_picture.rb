class MakeupPicture < ActiveRecord::Base
  belongs_to :picture
  belongs_to :makeup
  acts_as_list :scope => :makeup_id
end
