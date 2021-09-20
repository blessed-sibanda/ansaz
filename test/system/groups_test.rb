require "application_system_test_case"

class GroupsTest < ApplicationSystemTestCase
  setup do
    @groups = create_list :group, 5
    @group = create :group
    @user = create :user
  end

  test "visiting the index" do
    login_as @user
    visit groups_url
    assert_selector "h1", text: "Groups"
    Group.ranked.paginate(page: 1, per_page: 15).each do |g|
      assert_text g.name
    end
  end

  test "creating a Group" do
    login_as @user
    visit root_url
    click_on "Create Group"

    fill_in "Name", with: "Cooking Club"
    fill_in "Description", with: "A group about cooking"
    select "Public", from: "Group type"

    click_on "Create Group"

    assert_text "Group was successfully created"
  end

  test "updating a Group" do
    login_as @group.admin
    visit group_url(@group)
    click_on "Edit", match: :first

    select "Private", from: "Group type"
    fill_in "Name", with: "Best Chefs"
    click_on "Update Group"

    assert_text "Group was successfully updated"
  end

  test "destroying a Group" do
    login_as @group.admin
    visit group_url(@group)
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Group was successfully destroyed"
  end
end
