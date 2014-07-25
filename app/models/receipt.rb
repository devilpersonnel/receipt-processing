class Receipt < ActiveRecord::Base
  serialize :lines, Array

  has_attached_file :image, :default_url => ""
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  belongs_to :user

  def image_url
    self.image.url
  end
  
end
