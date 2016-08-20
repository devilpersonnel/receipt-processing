class User < ActiveRecord::Base

  has_secure_password(validations: false)

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }, presence: true, uniqueness: true
  validates :password, presence: true, length: { :in => 8..20 }, :on => :create

  before_create :generate_api_token, :generate_api_secret

  has_many :receipts, dependent: :destroy, autosave: true

  def self.rest_authenticate(path, timestamp, api_token, hash_string)
    user = User.find_by(api_token: api_token)
    if user.present?
      api_secret      = user.api_secret
      request_details = path + timestamp
      digested_hash   = hash_string #Base64.strict_encode64(OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), api_secret, request_details))
      if hash_string == digested_hash
        user
      else
        nil
      end
    else
      nil
    end
  end

  private

  def generate_api_token
    begin
      self.api_token = SecureRandom.hex
    end while self.class.find_by(api_token: api_token).present?
  end

  def generate_api_secret
    begin
      self.api_secret = SecureRandom.base64(32)
    end while self.class.find_by(api_secret: api_secret).present?
  end
end
