module GroupsHelper
  def group_banner(group, height:, width:)
    render partial: "groups/banner_img",
           locals: { group: group,
                     height: height,
                     width: width }
  end
end
