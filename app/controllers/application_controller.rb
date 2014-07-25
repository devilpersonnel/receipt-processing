class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  rescue_from CustomError, :with => :custom_message

  def restrict_access
    path        = "/#{params[:controller]}"
    timestamp   = "#{params[:timestamp]}"
    api_token   = params[:api_token]
    hash_string = request.headers["Rest-Signature"]
    if !path.present? || !timestamp.present? || !api_token.present? || !hash_string.present?
      raise CustomError.new("invalid_credentials", 401)
    else
      @api_user = User.rest_authenticate(path, timestamp, api_token, hash_string)
      if @api_user.nil?
        raise CustomError.new("invalid_credentials", 401)
      end
    end
  end

  private

  def custom_message(exception)
    render :json => { :meta => { :code => exception.status_code, :message => exception.message }}, :status => 200
  end
  
end
