class Post < ActiveRecord::Base
  belongs_to :topic
  acts_as_tree :order => 'created_at'
end 
