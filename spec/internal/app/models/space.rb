class Space < ActiveRecord::Base
  belongs_to :floor

  has_many :targeted_by, class_name: 'right'

  has_one :prop, through: :floor, source: :property
  has_one :acc, through: :targeted_by, source: :account
end
