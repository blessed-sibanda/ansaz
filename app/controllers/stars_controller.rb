class StarsController < ApplicationController
  def create
    @star = current_user.stars.new(stars_params)
    @star.save
    respond_to do |format|
      format.js { render "stars" }
    end
  end

  def destroy
    @star = Star.find(params[:id])
    authorize @star
    @star.destroy
    respond_to do |format|
      format.js { render "stars" }
    end
  end

  private

  def stars_params
    params.permit(:starrable_id, :starrable_type)
  end
end
