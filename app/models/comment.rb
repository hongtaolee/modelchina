class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :model, :counter_cache => true
  belongs_to :photographer, :counter_cache => true
  belongs_to :makeup, :counter_cache => true
  validates_presence_of :user_id, :text  
  def after_save
    Spam.comment(self.id)
  end
end
