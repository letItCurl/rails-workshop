require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "tag requires a name" do
    tag = Tag.new(name: "")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "tag name must be unique" do
    Tag.create!(name: "Ruby")
    duplicate = Tag.new(name: "Ruby")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "post can have many tags via has_many through" do
    post = Post.create!(title: "Test", body: "content")
    tag1 = Tag.create!(name: "Alpha")
    tag2 = Tag.create!(name: "Beta")

    post.tags << tag1
    post.tags << tag2

    assert_equal 2, post.tags.count
    assert_includes post.tags, tag1
    assert_includes post.tags, tag2
  end

  test "tag can have many posts (bidirectional)" do
    tag = Tag.create!(name: "Gamma")
    post1 = Post.create!(title: "Post 1", body: "content")
    post2 = Post.create!(title: "Post 2", body: "content")

    tag.posts << post1
    tag.posts << post2

    assert_equal 2, tag.posts.count
    assert_includes tag.posts, post1
    assert_includes tag.posts, post2
  end

  test "deleting a post removes post_tags but not the tag" do
    post = Post.create!(title: "Test", body: "content")
    tag = Tag.create!(name: "Delta")
    post.tags << tag

    assert_equal 1, PostTag.count
    post.destroy!
    assert_equal 0, PostTag.count
    assert Tag.exists?(tag.id), "Tag should still exist"
  end
end
