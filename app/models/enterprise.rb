class Enterprise < ActiveRecord::Base
  has_one :avata  , :dependent => :destroy
  belongs_to :user
end
