class PapersController < ApplicationController
  def index
  @papers=Paper.all
  end
  def new
    @paper = Paper.new
  end
  def create
    @paper = Paper.create(user_params)
    redirect_to papers_path
  end
  def show
    @paper=Paper.find(params[:id])
  end
  private
  def user_params
    params.require(:paper).permit(:avatar)
  end
end
