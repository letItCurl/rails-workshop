---
branch: 05-comments-authorization
title: "Authorization — You Missed a Business Rule"
lang: en
pair: guide-th.md
day: 1
time: "13:40–13:50"
duration: 10min
difficulty: 🟡 Recipe + Why
prerequisite: 05-comments
next: 06-tags
rails_guide: https://guides.rubyonrails.org/action_controller_overview.html
aha_moment: "Tests pass ≠ correct — if you don't test the business rule you forgot, it'll never fail"
business_rule: "Only the owner can delete their own comment/post"
---

# ⚠️ You Missed Something

Stop. Go back and look at the code you just wrote.

All tests pass. Comments work. Can't edit them. Looks complete.

**But...** log in as User A and try deleting User B's comment.

Does it work?

**Yes.** And that's a bug.

We tested "comment needs a post" and "comment needs a user" — but we never tested **"only the owner can delete their own comment."**

CI passes every test, but the app has a security hole. This is what it means when we say "test coverage doesn't tell you the app is correct."

---

## Write the Test First

This isn't a model test — it's controller behavior. Create:

```bash
mkdir -p test/controllers
```

Open `test/controllers/comments_controller_test.rb`:

```ruby
require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email: "owner@test.com", password: "password")
    @other = User.create!(email: "other@test.com", password: "password")
    @post = Post.create!(title: "Test", body: "content", user: @owner)
    @comment = Comment.create!(body: "My truth", post: @post, user: @owner)
  end

  test "owner can delete their own comment" do
    sign_in @owner
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
```

Run:

```bash
rails test test/controllers/comments_controller_test.rb
```

**The second test will FAIL** — because right now anyone can delete anything.

---

## Fix: Only Owner Can Delete

Edit `app/controllers/comments_controller.rb`, update `destroy`:

```ruby
def destroy
  if @comment.user == current_user
    post = @comment.post
    @comment.destroy!
    redirect_to post_path(post), notice: "Comment was successfully destroyed.", status: :see_other
  else
    redirect_to post_path(@comment.post), alert: "You can only delete your own comments."
  end
end
```

Do the same for posts — edit `app/controllers/posts_controller.rb`:

```ruby
before_action :authorize_owner!, only: %i[ edit update destroy ]

# ... existing actions ...

private

def authorize_owner!
  unless @post.user == current_user
    redirect_to posts_path, alert: "You can only edit/delete your own posts."
  end
end
```

Run all tests:

```bash
rails test
```

**All tests should pass.**

---

## 🧪 Quick Check

1. **Why didn't the previous tests catch this bug?**
2. **Does 100% test coverage mean no bugs?**
3. **What's the difference between authentication and authorization?**

**Discuss:** "If you build a multi-tenant SaaS and forget to scope your queries — CI passes but customer data leaks." Sound familiar?

---

## ✅ Before You Move On

- [ ] Only comment owner can delete their comment
- [ ] Only post owner can edit/delete their post
- [ ] Test proves other users can't delete someone else's comment
- [ ] Understand that passing tests ≠ no bugs

---

## ➡️ Next: Branch `06-tags`

Posts need categories — this is "the one kick."
