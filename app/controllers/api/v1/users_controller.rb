class Api::V1::UsersController < ApplicationController
  
  def create
    raise CustomError.new("Email can't be blank.", 412) unless params[:email].present?
    raise CustomError.new("Password can't be blank.", 412) unless params[:password].present?
    email = params[:email]
    password = params[:password]
    user = User.new(:email => email, :password => password)
    raise CustomError.new(user.errors.messages, 412) unless user.valid?
    if user.save
      render :json => { :user_id => user.id, :api_token => user.api_token, :api_secret => user.api_secret, :meta => { :code => 200, :message => "Success" }}
    else
      raise CustomError.new("Something went wrong. Please try again.", 400)
    end
  end

  def login
    raise CustomError.new("Email can't be blank.", 412) unless params[:email].present?
    raise CustomError.new("Password can't be blank.", 412) unless params[:password].present?
    email = params[:email]
    password = params[:password]
    user = User.find_by(email: email).try(:authenticate, password)
    if user.present?
      render :json => { :user_id => user.id, :api_token => user.api_token, :api_secret => user.api_secret, :meta => { :code => 200, :message => "Success" }}
    else
      raise CustomError.new("Authentication failed", 401)
    end
  end

end