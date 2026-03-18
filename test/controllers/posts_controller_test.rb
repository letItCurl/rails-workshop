require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email: "owner@test.com", password: "password")
    @other = User.create!(email: "other@test.com", password: "password")
    @post = Post.create!(title: "My Truth", body: "content", user: @owner)
  end

  test "owner can delete their own post" do
    sign_in @owner
    assert_difference("Post.count", -1) do
      delete post_path(@post)
    end
  end

  test "other user cannot delete someone else's post" do
    sign_in @other
    delete post_path(@post)
    assert_response :redirect
    assert Post.exists?(@post.id), "Post should still exist"
  end

  test "owner can edit their own post" do
    sign_in @owner
    get edit_post_path(@post)
    assert_response :success
  end

  test "other user cannot edit someone else's post" do
    sign_in @other
    get edit_post_path(@post)
    assert_response :redirect
  end
end
