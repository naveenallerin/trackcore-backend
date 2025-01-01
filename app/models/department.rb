class Department < ApplicationRecord
  has_many :requisitions
  has_many :users
  
  validates :name, presence: true, uniqueness: true
end
