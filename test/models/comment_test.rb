require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "comment requires a post" do
    user = User.create!(email: "test@test.com", password: "password")
    comment = Comment.new(body: "test", user: user, post: nil)
    assert_not comment.valid?
  end

  test "comment requires a user" do
    post = Post.create!(title: "Test", body: "content")
    comment = Comment.new(body: "test", post: post, user: nil)
    assert_not comment.valid?
  end

  test "valid comment can be created" do
    user = User.create!(email: "test2@test.com", password: "password")
    post = Post.create!(title: "Test", body: "content")
    comment = Comment.new(body: "Great truth!", post: post, user: user)
    assert comment.valid?
  end
end
