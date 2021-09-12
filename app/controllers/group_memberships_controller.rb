class GroupMembershipsController < ApplicationController
  before_action :set_group, only: %i[update destroy]

  def update
    flash[:notice] = GroupMembership::Creator.call(
      user: current_user, group: @group,
    )
    redirect_back(fallback_location: root_path)
  end

  def destroy
    if current_user == @group.admin
      redirect_back(fallback_location: root_path, alert: "Group admin cannot leave")
    else
      GroupMembership.where(user: current_user,
                            group: @group).first.destroy
      redirect_to root_path, alert: "You have left '#{@group.name}' group"
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
