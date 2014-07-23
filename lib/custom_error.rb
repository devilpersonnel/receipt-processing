class CustomError < StandardError
  attr_accessor :message, :status_code
  def initialize(msg = "You've triggered a MyError", status=500)
   @message = msg
   @status_code = status
  end
end