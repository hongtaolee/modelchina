class Job < ActiveRecord::Base
  def after_save
    Spam.job(self.id)
  end
end
