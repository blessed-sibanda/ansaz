require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create :user
    sign_in @user
  end

  test "#index should get tags matching the given params" do
    tags = ["technology", "food", "health", "finance", "education"]
    tags.each { |name| ActsAsTaggableOn::Tag.create(name: name) }
    get tags_url(q: "f")
    assert_response :success

    # 2 tags matching 'f' will be returned (i.e food & finance)
    assert_select ".list-group-item", 2
    assert_select ".list-group-item", "food"
    assert_select ".list-group-item", "finance"
  end

  test "#show should return questions matching the tag" do
    q1 = create :question, tag_list: ["react", "javascript"]
    q2 = create :question, tag_list: ["god", "religion"]
    q3 = create :question, tag_list: ["web-dev", "react", "rails"]

    get tag_url(id: "react")

    assert_select "#question_#{q1.id}" do
      assert_select "a[href=?]", question_path(q1), text: q1.title
    end

    # q2 is not return since it doesn't contain 'react' tag
    assert_select "#question_#{q2.id}", count: 0

    assert_select "#question_#{q3.id}" do
      assert_select "a[href=?]", question_path(q3), text: q3.title
    end
  end
end
