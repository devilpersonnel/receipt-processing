class WelcomeController < ApplicationController
  def index
    render :json => { :message => "Welcome to Receipt Processing API Service"}
  end
end