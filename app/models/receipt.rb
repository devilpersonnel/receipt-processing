class Receipt < ActiveRecord::Base
  serialize :lines, Array

  belongs_to :user
  
end
