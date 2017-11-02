class Right < ActiveRecord::Base
  belongs_to :space
  belongs_to :floor
  belongs_to :account

  has_many :lease_terms
end
