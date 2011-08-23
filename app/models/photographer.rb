class Photographer < ActiveRecord::Base
  has_one :avata,:dependent => :destroy
  has_many :photographer_pictures,:dependent => :delete_all,:order => 'position DESC'
  has_many :pictures , :through => :photographer_pictures, :order => 'position DESC'
  has_many :comments, :conditions => ["status>0"], :dependent => :delete_all
  belongs_to :user
  acts_as_taggable :join_class_name => 'TagPhotographer'
end
