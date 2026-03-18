---
branch: 01-foundation
title: "Foundation — Your First App"
lang: en
pair: guide-th.md
day: 1
time: "9:50–10:30"
duration: 40min
difficulty: "\U0001F7E2 Recipe"
prerequisite: 00-start
next: 02-posts
rails_guide: https://guides.rubyonrails.org/getting_started.html
aha_moment: "3 commands = working app"
business_rule: "Posts are public — anyone can read, anyone can create"
---

# Foundation — Your First App

## Ever started a project from scratch?

You know that feeling when you start a React/Next project? You have to set up routing, create API endpoints, write migrations, configure the database, wire up an ORM... by the time you see the first page on screen, an hour has gone by.

In Rails, we'll do all of that in 3 commands.

Ask yourself this:

> **If one command could build an app, what would you build?**

Today we're building **Oddly Honest** — a blog where anyone can post and anyone can read. Straightforward and simple.

---

## Let's Go

### 1. Create the Rails App

```bash
rails new . -d postgresql --css tailwind --name oddly_honest
```

This single command generates the entire app structure — config files, database.yml, Gemfile, and Tailwind CSS ready to go.

### 2. Create the Database

```bash
rails db:create
```

This creates the PostgreSQL database automatically. No need to open psql yourself.

### 3. Generate the Post Scaffold

```bash
rails g scaffold Post title:string body:text
```

This one command generates everything:

- **Model** (`app/models/post.rb`) — represents data in the database
- **Controller** (`app/controllers/posts_controller.rb`) — handles requests across all 7 actions (index, show, new, create, edit, update, destroy)
- **Views** (`app/views/posts/`) — web pages for listing, showing, creating, and editing
- **Migration** (`db/migrate/..._create_posts.rb`) — the instruction to create the posts table in the database
- **Routes** — all URL paths for posts

### 4. Run the Migration

```bash
rails db:migrate
```

### 5. Start the Server

```bash
bin/dev
```

### 6. Open Your Browser

Go to [http://localhost:3000/posts](http://localhost:3000/posts)

Try creating a post, editing it, deleting it — full CRUD, ready to go!

---

## What Did Scaffold Generate?

Take a look at these files:

| File | Purpose |
|---|---|
| `app/models/post.rb` | Model — represents data |
| `app/controllers/posts_controller.rb` | Controller — handles logic |
| `app/views/posts/` | Views — web pages |
| `db/migrate/..._create_posts.rb` | Migration — creates the table |
| `config/routes.rb` | Routes — URL paths |

Open `config/routes.rb` and you'll see:

```ruby
resources :posts
```

This single line generates 7 routes. Try running `rails routes` to see them all.

---

## Checkpoint Questions

### 1. Count the Commands
From zero to a working app — how many commands did it take?

### 2. React Comparison
If you had to build the same CRUD app in React/Next, how long would it take?

### 3. What's in routes.rb?
Open `config/routes.rb` and describe what you see.

---

## Self-Check

- [ ] App runs at localhost:3000/posts
- [ ] Can create a new post
- [ ] Can edit a post
- [ ] Can delete a post
- [ ] Opened `config/routes.rb` and understand what `resources :posts` does

---

## Up Next: 02-posts

We now have full CRUD, but posts have no validation — anyone can submit a blank post. In the next step, we'll make the app smarter by adding validations and polishing the views.
