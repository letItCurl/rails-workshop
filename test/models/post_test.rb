require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "draft post can be updated" do
    post = Post.create!(title: "Draft", body: "content", published: false)
    post.update!(title: "Updated Draft")
    assert_equal "Updated Draft", post.title
  end

  test "published post cannot be updated" do
    post = Post.create!(title: "Truth", body: "content", published: true)
    post.title = "Edited Truth"
    assert_not post.valid?
    assert_includes post.errors[:base], "Published posts cannot be edited"
  end

  test "draft post can be published" do
    post = Post.create!(title: "Draft", body: "content", published: false)
    post.update!(published: true)
    assert post.published?
  end
end
