---
branch: 02-posts
title: "Posts — Read Routes, See SQL"
lang: en
pair: guide-th.md
day: 1
time: "10:30–11:00"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 01-foundation
next: 03-auth
rails_guide: https://guides.rubyonrails.org/routing.html
aha_moment: "The database IS the design — read the whole app from 2 files"
business_rule: "Post.all → SELECT * FROM posts — no magic"
---

# 🔍 Read the Whole App from 2 Files

You have a working app. You can create posts, edit them, delete them. But ask yourself — do you really *understand* it?

If someone dropped a Rails app on your desk — thousands of lines of code, dozens of controllers and models — where would you start reading?

The answer is **2 files**: `config/routes.rb` and `db/schema.rb`.

If you can read those two files, you understand the whole app.

---

## Read the Routes

Open terminal and run:

```bash
rails routes
```

What you see is **every URL** the app responds to. Every HTTP method (GET, POST, PATCH, DELETE). Every controller action.

Open `config/routes.rb`:

```ruby
resources :posts
```

One line. Creates 7 routes — index, show, new, create, edit, update, destroy.

**Think about it:** In React/Next, how many files do you need to create for the same set of routes?

---

## Read the Schema

Open `db/schema.rb`:

```ruby
create_table "posts", force: :cascade do |t|
  t.string "title"
  t.text "body"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

This is **your entire database**. Every table, every column, one file.

Routes tell you what the app can do. Schema tells you what the app stores. **These two files are the entire blueprint.**

---

## See the SQL Underneath

Open the Rails console:

```bash
rails console
```

Try:

```ruby
Post.all
```

Look at the terminal — see the SQL?

```sql
SELECT "posts".* FROM "posts"
```

ActiveRecord isn't doing magic. It just writes SQL for you. Every time you call a method, it generates a SQL string and executes it against the database.

Try more:

```ruby
Post.create(title: "test", body: "hello world")
```

See the SQL — `INSERT INTO "posts"`.

```ruby
Post.where(title: "test")
```

See the SQL — `WHERE "posts"."title" = $1`.

```ruby
Post.first
```

See the SQL — `LIMIT 1`.

**Every method = readable SQL.** No magic hiding underneath.

---

## 🧪 Quick Check

1. **How many routes does `resources :posts` create?** (count from `rails routes`)
2. **What SQL does `Post.all` generate?**
3. **If you had to read a Rails app you've never seen, what two files do you open first?**

**Discuss with your neighbor:** What does "Read the routes, know the database" mean?

---

## ✅ Before You Move On

- [ ] Read `config/routes.rb` and understand what `resources :posts` creates
- [ ] Read `db/schema.rb` and understand the posts table structure
- [ ] Saw the SQL in rails console that ActiveRecord generates
- [ ] Can explain what "Read the routes, know the database" means

---

## ➡️ Next: Branch `03-auth`

Anyone can post. Anyone can edit. Anyone can delete. But *who* posted it? We need users.
