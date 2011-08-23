class Referral < ActiveRecord::Base
  belongs_to :referral_user
  belongs_to :referral_forum
end
