---
branch: 05-comments
title: "Comments — Permanent Reactions"
lang: en
pair: guide-th.md
day: 1
time: "13:15–13:50"
duration: 35min
difficulty: 🟡 Recipe + Why
prerequisite: 04-publish-rules
next: 06-tags
rails_guide: https://guides.rubyonrails.org/association_basics.html
aha_moment: "Scaffold gives you full CRUD, then you choose what to remove — that's a business decision"
business_rule: "Must login to comment. Comments can never be edited."
---

# 💬 Users Want to React — What's the Relationship?

A post can exist on its own. A comment can't — it must *belong to* a post and *belong to* a user.

Think before coding: what does a comment connect to?

- Comment → Post (which post is it on?)
- Comment → User (who wrote it?)

In the database, that means the comments table needs `post_id` and `user_id` — that's `belongs_to`.

**Question:** What does `belongs_to` mean in database terms? (hint: foreign key)

---

## Scaffold Comment

```bash
rails g scaffold Comment body:text post:references user:references
```

**Notice what was generated:**
- `app/models/comment.rb` — already has `belongs_to :post` and `belongs_to :user`!
- `db/migrate/..._create_comments.rb` — with foreign keys
- `app/controllers/comments_controller.rb` — full CRUD
- `app/views/comments/` — all views

```bash
rails db:migrate
```

Open `db/schema.rb` — see the comments table? Has `post_id` and `user_id`.

---

## Wire the Models

Scaffold already created `belongs_to` in Comment. But Post and User need to know about comments:

Edit `app/models/post.rb`, add:

```ruby
has_many :comments, dependent: :destroy
```

Edit `app/models/user.rb`, add:

```ruby
has_many :comments, dependent: :destroy
```

**Think:** `dependent: :destroy` means: delete a post → all its comments get destroyed. Delete a user → all their comments get destroyed.

---

## Remove Edit/Update — Business Decision

Here's the key moment: scaffold gave you full CRUD. But OddlyHonest's rule is **comments can never be edited**. You said it, it's done.

Edit `config/routes.rb`, change:

```ruby
resources :comments
```

to:

```ruby
resources :comments, except: [:edit, :update]
```

Open `app/controllers/comments_controller.rb` — **delete** the `edit` and `update` actions entirely.

Delete `app/views/comments/edit.html.erb`.

**This is the aha moment:** Rails gives you everything, then you choose what to remove. It's not about adding features — it's about making business decisions about what to keep.

---

## Lock Comments Behind Login

Edit `app/controllers/comments_controller.rb`, add:

```ruby
before_action :authenticate_user!, except: [:index, :show]
```

Update the `create` action:

```ruby
def create
  @comment = current_user.comments.build(comment_params)
  if @comment.save
    redirect_to post_path(@comment.post), notice: "Comment was successfully created."
  else
    redirect_to post_path(@comment.post), alert: "Comment could not be created."
  end
end
```

---

## Show Comments on Post Page

Edit `app/views/posts/show.html.erb`, add a comments section:

```erb
<h2 class="font-bold text-2xl mt-8 mb-4">Comments</h2>

<% @post.comments.each do |comment| %>
  <div class="border-b border-gray-200 py-3">
    <p class="text-gray-800"><%= comment.body %></p>
    <p class="text-sm text-gray-500"><%= comment.user&.email %> — <%= time_ago_in_words(comment.created_at) %> ago</p>
  </div>
<% end %>

<% if user_signed_in? %>
  <h3 class="font-medium text-lg mt-6 mb-2">Add a comment</h3>
  <%= form_with(model: Comment.new, url: comments_path) do |f| %>
    <%= f.hidden_field :post_id, value: @post.id %>
    <div class="mb-3">
      <%= f.text_area :body, rows: 3, placeholder: "Share your truth...",
          class: "w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" %>
    </div>
    <%= f.submit "Comment", class: "bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 cursor-pointer" %>
  <% end %>
<% end %>
```

---

## 🧪 Quick Check

1. **What does `belongs_to :post` in Comment mean in the database?** (hint: which column?)
2. **Why remove edit/update from routes instead of just hiding the button?**
3. **What does `dependent: :destroy` do? What happens if you don't include it?**

---

## 🧪 Write a Test Yourself

**🔴 Challenge:**

> Write a test that proves: a comment cannot be created without a post (post_id = nil)

If stuck >5 min:
- 💡 Hint 1: Use `test/models/comment_test.rb`
- 💡 Hint 2: `Comment.new(body: "test", user: user, post: nil)`
- 💡 Hint 3: `assert_not comment.valid?`

---

## ✅ Before You Move On

- [ ] Comment scaffold created with both belongs_to
- [ ] Post has_many :comments, User has_many :comments
- [ ] Edit/update routes removed — comments can never be edited
- [ ] Must login to comment
- [ ] Comments display on post page
- [ ] Understand `belongs_to` and `dependent: :destroy`

---

## ➡️ Next: Branch `06-tags`

Posts need categories. But a post has many tags AND a tag has many posts — how? This is "the one kick."
