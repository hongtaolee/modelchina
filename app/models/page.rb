class Page < ActiveRecord::Base
  has_one :page_content
  acts_as_taggable :join_class_name => 'TagPage'
end
