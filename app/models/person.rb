
class Person < ApplicationRecord
  # ...existing code...
  
  def age
    read_attribute(:age)
  end
  
  # ...existing code...
end