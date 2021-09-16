class UsersController < ApplicationController
  def index
    @users = User.active.ranked.paginate(
      per_page: 20,
      page: params[:page],
    )
  end

  def show
    @user = User.find(params[:id])
  end
end
