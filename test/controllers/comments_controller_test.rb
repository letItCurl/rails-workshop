require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post_author = User.create!(email: "author@test.com", password: "password")
    @commenter = User.create!(email: "commenter@test.com", password: "password")
    @other = User.create!(email: "other@test.com", password: "password")
    @post = Post.create!(title: "Test", body: "content", user: @post_author)
    @comment = Comment.create!(body: "My truth", post: @post, user: @commenter)
  end

  test "comment owner can delete their own comment" do
    sign_in @commenter
    assert_difference("Comment.count", -1) do
      delete comment_path(@comment)
    end
  end

  test "post author can delete any comment on their post" do
    sign_in @post_author
    assert_difference("Comment.count", -1) do
      delete comment_path(@comment)
    end
  end

  test "other user cannot delete someone else's comment" do
    sign_in @other
    delete comment_path(@comment)
    assert_response :redirect
    assert Comment.exists?(@comment.id), "Comment should still exist"
  end
end
