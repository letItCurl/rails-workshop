---
branch: 05-polish
title: "Polish — Validations + Honest UI"
lang: en
pair: guide-th.md
day: 1
time: "13:45–13:50"
duration: 5min
difficulty: 🟢 Recipe
prerequisite: 05-comments-authorization
next: 06-tags
rails_guide: https://guides.rubyonrails.org/active_record_validations.html
aha_moment: "Defense in depth — block at model, block at controller, hide at view"
business_rule: "Posts need title+body, comments need body, UI doesn't show buttons you can't use"
---

# 🧹 Make the App Honest

Before moving on, two things need fixing:

**Problem 1:** Try creating an empty post — no title, no body. Hit save.

Does it work? **Yes.** And it shouldn't.

**Problem 2:** Log in as User A and look at User B's post — see the Edit and Delete buttons?

You can see them, but clicking redirects you back. Controller blocks it, but the UI lies to the user.

---

## Add Validations

Edit `app/models/post.rb`, add:

```ruby
validates :title, presence: true
validates :body, presence: true
```

Edit `app/models/comment.rb`, add:

```ruby
validates :body, presence: true
```

Test in console:

```ruby
rails console
Post.create(title: "", body: "")  # should fail
Comment.create(body: "")           # should fail
```

---

## Hide Buttons for Non-Owners

Edit `app/views/posts/show.html.erb` — wrap Edit, Publish, Delete buttons:

```erb
<% if current_user == @post.user %>
  <%# ... edit, publish, delete buttons ... %>
<% end %>
```

Same for comment delete — show only to comment owner or post author:

```erb
<% if current_user == comment.user || current_user == @post.user %>
  <%# ... delete link ... %>
<% end %>
```

**Principle:** Defense in depth — all 3 layers protect:
1. **Model** — validations block bad data
2. **Controller** — authorization blocks unauthorized actions
3. **View** — UI doesn't show things you can't do

---

## ✅ Before You Move On

- [ ] Empty posts can't be created
- [ ] Empty comments can't be created
- [ ] Non-owners don't see Edit/Delete buttons
- [ ] Owners see buttons normally

---

## ➡️ Next: Branch `06-tags`

Here it comes — has_many :through, the one kick
