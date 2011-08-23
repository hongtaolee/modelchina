class Topic < ActiveRecord::Base
  validates_presence_of :title, :on => :create, :message => "标题不能为空"
  has_many :posts
  belongs_to :user
  def after_save
    Spam.topic(self.id)
  end
end
