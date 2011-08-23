class Model < ActiveRecord::Base
  has_one :avata,:dependent => :destroy
  has_many :model_pictures,:dependent => :delete_all,:order => 'position DESC'
  has_many :pictures , :through => :model_pictures, :order => 'position DESC'
  has_many :comments, :conditions => ["status>0"], :dependent => :delete_all
  belongs_to :user
  acts_as_taggable :join_class_name => 'TagModel'
end
