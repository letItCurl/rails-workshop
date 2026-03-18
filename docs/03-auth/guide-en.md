---
branch: 03-auth
title: "Auth — Who Posted This?"
lang: en
pair: guide-th.md
day: 1
time: "11:15–11:45"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 02-posts
next: 04-publish-rules
rails_guide: https://guides.rubyonrails.org/security.html
aha_moment: "Auth in 3 commands — how long did this take on your last project?"
business_rule: "Must login to create posts. Anyone can read."
---

# 🔐 Who Posted This?

Right now our app has a problem — anyone can post, anyone can edit, anyone can delete. No idea who wrote what.

Think business: "OddlyHonest is a platform where everyone can read, but you must login to post."

**Question:** How long does it take you to build an auth system in React/Next? A week? Two weeks?

---

## Install Devise

Devise is the most popular authentication gem in the Rails community. No building auth from scratch:

```bash
bundle add devise
```

```bash
rails g devise:install
```

**Notice:** Devise tells you what to do in the terminal output — read and follow the instructions.

---

## Create User Model

```bash
rails g devise User
```

**Notice what was generated:**
- `app/models/user.rb` — User model with Devise modules
- `db/migrate/..._devise_create_users.rb` — migration creates users table
- `config/routes.rb` — adds `devise_for :users` automatically

```bash
rails db:migrate
```

Open `db/schema.rb` — see the `users` table? Email, encrypted_password, everything auth needs.

---

## Wire User to Post

Posts need to know who owns them — add `user_id`:

```bash
rails g migration AddUserToPosts user:references
rails db:migrate
```

Edit `app/models/post.rb`:

```ruby
belongs_to :user
```

Edit `app/models/user.rb`:

```ruby
has_many :posts, dependent: :destroy
```

**Think about it:** `belongs_to` means a Post cannot exist without a User — the relationship lives in the database (foreign key).

---

## Lock Down Post Creation

Edit `app/controllers/posts_controller.rb`, add at the top of the class:

```ruby
before_action :authenticate_user!, except: [:index, :show]
```

Update the `create` action to build through current_user:

```ruby
def create
  @post = current_user.posts.build(post_params)
  # ... rest stays the same
end
```

---

## Test It

1. Visit `/posts` → **see posts** (no login needed)
2. Click "New post" → **redirected to login** (must login first)
3. Sign up → login → create a post → **works!**

---

## 🧪 Quick Check

1. **What does `belongs_to :user` in Post model mean?**
2. **If you delete a User — what happens to their posts?** (hint: check `dependent: :destroy`)
3. **What does `before_action :authenticate_user!, except: [:index, :show]` do?**

**Discuss:** 3 commands (bundle add, devise:install, devise User) gave you a full auth system — signup, login, logout, password reset. How long did this take on your last project?

---

## ✅ Before You Move On

- [ ] Devise installed, User model exists
- [ ] Post belongs_to :user
- [ ] Can read posts without login
- [ ] Must login to create posts
- [ ] Understand `belongs_to` and `has_many`

---

## ➡️ Next: Branch `04-publish-rules`

Auth works. But if a post is published — should you be able to edit it? "You said it, you own it."
