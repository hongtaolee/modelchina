class Group < ActiveRecord::Base
  has_many :members
  has_one :avata  , :dependent => :destroy
  has_many :topics
  acts_as_taggable :join_class_name => 'TagGroup'
end
