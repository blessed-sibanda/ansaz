class GroupMembershipsController < ApplicationController
  before_action :set_group, only: %i[update destroy]
  before_action :set_group_membership, only: %i[accept reject]

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

  def accept
    @group_membership.state = GroupMembership::ACCEPTED
    @group_membership.save!
    redirect_back(fallback_location: root_path)
  end

  def reject
    @group_membership.destroy
    redirect_back(fallback_location: root_path)
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def set_group_membership
    @group_membership = GroupMembership.find(params[:id])
    authorize @group_membership, :accept_or_reject?
  end
end
