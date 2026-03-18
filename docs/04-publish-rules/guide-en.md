---
branch: 04-publish-rules
title: "Publish Rules — Can't Edit Once Published"
lang: en
pair: guide-th.md
day: 1
time: "11:45–12:15"
duration: 30min
difficulty: 🟡 Recipe + Why
prerequisite: 03-auth
next: 05-comments
rails_guide: https://guides.rubyonrails.org/active_record_validations.html
aha_moment: "Business rules live in the model — even if the controller has a bug, the data is safe"
business_rule: "Published posts cannot be edited — you said it, you own it"
---

# 🔒 You Said It — No Take-Backs

OddlyHonest is a platform for sharing truths. If you publish it — it's real. Can't edit it. Like words spoken out loud, you can't take them back.

Sounds like a simple business rule. But the question is: **where do we enforce it?**

- In the frontend? (hide the edit button) → trivially bypassed
- In the controller? (check before update) → better, but what if multiple controllers update posts?
- **In the model** → **correct** — no matter where the update comes from, the rule always protects the data

**This is the principle: Business rules live in the model.**

---

## Add the published field

```bash
rails g migration AddPublishedToPosts published:boolean
```

Open the migration file — add a default value:

```ruby
add_column :posts, :published, :boolean, default: false
```

```bash
rails db:migrate
```

Open `db/schema.rb` — see the `published` column in the posts table?

---

## Write the test FIRST

**Before writing any code — write the test.** If the test passes before we write the validation, our test is wrong.

Generate a test file:

```bash
rails g test_unit:model post
```

Open `test/models/post_test.rb` and write:

```ruby
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
end
```

Run it:

```bash
rails test test/models/post_test.rb
```

**It should FAIL** — because we haven't written the validation yet. That's correct. If the test passes now, the test isn't testing anything.

---

## Write the validation in the model

Open `app/models/post.rb` and add:

```ruby
validate :cannot_edit_once_published

private

def cannot_edit_once_published
  if published? && changed? && !published_changed?
    errors.add(:base, "Published posts cannot be edited")
  end
end
```

**Read this code:** If the post is published (`published?`) AND something changed (`changed?`) BUT it's not the published field itself changing (`!published_changed?`) → block it.

This means: you CAN publish (change `published` from false to true), but after publishing, nothing else can change.

Run the test again:

```bash
rails test test/models/post_test.rb
```

**Both tests should pass.**

---

## Add publish button to UI

Open `app/views/posts/show.html.erb` and add a publish button:

```erb
<% unless @post.published? %>
  <%= button_to "Publish", post_path(@post), method: :patch,
      params: { post: { published: true } },
      class: "bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700" %>
<% end %>

<% if @post.published? %>
  <span class="inline-block bg-green-100 text-green-800 text-sm px-3 py-1 rounded-full">Published</span>
<% end %>
```

Don't forget to add `:published` to `post_params`:

```ruby
def post_params
  params.expect(post: [ :title, :body, :published ])
end
```

---

## 🧪 Quick Check

1. **Why does the validation live in the model, not the controller?**
2. **If the test passes BEFORE you write the validation — what does that mean?**
3. **What's the difference between `changed?` and `published_changed?`?**

**Discuss:** "CI might pass every test, but if you don't test THIS business rule, your app still leaks." What does that mean?

---

## 🧪 Write Another Test Yourself

**🔴 Challenge — no example given:**

> Write a test that proves: a draft post CAN be published (change published from false to true).

If stuck >5 min:
- 💡 Hint 1: Create a post with `published: false`
- 💡 Hint 2: Use `post.update!(published: true)`
- 💡 Hint 3: `assert post.published?`

---

## ✅ Before You Move On

- [ ] `published` column exists in posts table
- [ ] Test written BEFORE validation — failed first, then passed
- [ ] Published post cannot be edited (validation blocks it)
- [ ] Draft post can be published
- [ ] Understand why business rules belong in the model

---

## ➡️ Next: Branch `05-comments`

Users want to react to posts — what's the relationship? And like posts, comments can never be edited either.
