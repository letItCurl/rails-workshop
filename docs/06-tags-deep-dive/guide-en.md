---
branch: 06-tags-deep-dive
title: "Deep Dive — How has_many :through Actually Works"
lang: en
pair: guide-th.md
day: 1
time: "14:20–14:35"
duration: 15min
difficulty: 🟡 Recipe + Why
prerequisite: 06-tags
next: 07-rich-text-images
rails_guide: https://guides.rubyonrails.org/association_basics.html#the-has-many-through-association
aha_moment: "ActiveRecord chains = SQL JOINs — every method is readable SQL"
business_rule: "No new business rules — this step is pure understanding"
---

# 🔬 How Does has_many :through Actually Work?

You just built tags with has_many :through. It works. But do you really understand what's happening **underneath**?

No new code in this step — we're going to **dissect** what you just built. Look at the SQL, the tables, and what ActiveRecord does for you.

---

## What Do the 3 Tables Look Like?

Open `db/schema.rb` and focus on just 3 tables:

```
posts                post_tags              tags
┌──────────────┐     ┌──────────────┐      ┌──────────────┐
│ id           │     │ id           │      │ id           │
│ title        │     │ post_id  ──────────→│ name         │
│ body         │←──────── post_id   │      │ created_at   │
│ published    │     │ tag_id   ──────────→│ updated_at   │
│ user_id      │     │ created_at   │      └──────────────┘
│ created_at   │     │ updated_at   │
│ updated_at   │     └──────────────┘
└──────────────┘
```

**Notice:** `post_tags` has no `name`, no `body`, nothing but `post_id` and `tag_id`. It's just a **connector**.

With real data:

```
posts                post_tags              tags
┌────┬───────────┐   ┌────┬─────┬──────┐   ┌────┬──────────┐
│ id │ title     │   │ id │post │tag   │   │ id │ name     │
├────┼───────────┤   │    │_id  │_id   │   ├────┼──────────┤
│  1 │ Deadlines │   ├────┼─────┼──────┤   │  1 │ Ruby     │
│  2 │ Meetings  │   │  1 │  1  │  1   │   │  2 │ Rails    │
│  3 │ Simple    │   │  2 │  1  │  2   │   │  3 │ Database │
└────┴───────────┘   │  3 │  2  │  3   │   │  4 │ Testing  │
                     │  4 │  3  │  1   │   │  5 │ Hotwire  │
                     │  5 │  3  │  2   │   └────┴──────────┘
                     └────┴─────┴──────┘
```

**Read:** Post 1 ("Deadlines") has tags Ruby (row 1) and Rails (row 2). Post 3 ("Simple") has tags Ruby (row 4) and Rails (row 5).

**Ask the group:** What tags does Post 2 ("Meetings") have? Which posts have the tag "Ruby"?

---

## What Each Argument of has_many :through Does

Open `app/models/post.rb` and look at these two lines:

```ruby
has_many :post_tags, dependent: :destroy
has_many :tags, through: :post_tags
```

**Line 1:** `has_many :post_tags`
- Tells Rails: "A Post has many PostTag records"
- Rails knows to look for `post_id` in the `post_tags` table
- `dependent: :destroy` = delete a post → delete its post_tags too (but NOT the tags themselves)

**Line 2:** `has_many :tags, through: :post_tags`
- Tells Rails: "A Post has many Tags **through** PostTag"
- `:tags` = the association name (matches the Tag model)
- `through: :post_tags` = find tags by going **through** the post_tags table
- Rails generates the JOIN automatically

**Open tag.rb — same thing, reversed:**

```ruby
has_many :post_tags, dependent: :destroy
has_many :posts, through: :post_tags
```

---

## The Actual SQL Rails Generates

Open `rails console` and try each one:

### 1. Find tags for a post

```ruby
post = Post.first
post.tags
```

**SQL generated:**
```sql
SELECT "tags".* FROM "tags"
INNER JOIN "post_tags" ON "tags"."id" = "post_tags"."tag_id"
WHERE "post_tags"."post_id" = $1
```

**Read the SQL:** Start from `tags` table → JOIN with `post_tags` (connecting tags.id = post_tags.tag_id) → filter only post_tags where post_id matches our post.

### 2. Find posts for a tag (reverse)

```ruby
tag = Tag.first
tag.posts
```

**SQL generated:**
```sql
SELECT "posts".* FROM "posts"
INNER JOIN "post_tags" ON "posts"."id" = "post_tags"."post_id"
WHERE "post_tags"."tag_id" = $1
```

**Same structure, reversed!** Start from `posts` → JOIN with `post_tags` → filter by tag_id.

### 3. Add a tag to a post

```ruby
post.tags << Tag.find_by(name: "Database")
```

**SQL generated:**
```sql
INSERT INTO "post_tags" ("post_id", "tag_id", "created_at", "updated_at")
VALUES ($1, $2, $3, $4)
```

**Doesn't touch posts or tags at all!** Just creates a new row in `post_tags`.

### 4. Query across tables

```ruby
Post.joins(:tags).where(tags: { name: "Rails" })
```

**SQL generated:**
```sql
SELECT "posts".* FROM "posts"
INNER JOIN "post_tags" ON "post_tags"."post_id" = "posts"."id"
INNER JOIN "tags" ON "tags"."id" = "post_tags"."tag_id"
WHERE "tags"."name" = $1
```

**Two JOINs!** posts → post_tags → tags. Because posts and tags aren't directly connected — you go through post_tags.

---

## The Same Pattern Is Everywhere

Look at the associations already in our app:

```ruby
User.first.posts              # has_many :posts
User.first.posts.first.comments  # has_many :comments (through post)
User.first.comments           # has_many :comments (direct)
```

**Try chaining further:**

```ruby
# Find all tags a user has ever used
User.first.posts.includes(:tags).flat_map(&:tags).uniq.map(&:name)
```

**Try this:**

```ruby
# Find all users who have posted with the tag "Rails"
User.joins(posts: :tags).where(tags: { name: "Rails" }).distinct
```

**SQL generated:**
```sql
SELECT DISTINCT "users".* FROM "users"
INNER JOIN "posts" ON "posts"."user_id" = "users"."id"
INNER JOIN "post_tags" ON "post_tags"."post_id" = "posts"."id"
INNER JOIN "tags" ON "tags"."id" = "post_tags"."tag_id"
WHERE "tags"."name" = $1
```

**Three JOINs!** users → posts → post_tags → tags. Every ActiveRecord chain is readable SQL.

---

## Comparison: Without has_many :through

Imagine storing tags as a JSON array in the posts table:

```json
{ "title": "Deadlines", "tags": ["Ruby", "Rails"] }
```

**Problems:**
- Find posts with tag "Ruby"? → `WHERE tags @> '["Ruby"]'` (PostgreSQL-specific, slow, no index)
- List all tags? → Scan every row, extract unique values
- Rename a tag? → Update every row that contains it
- Count posts per tag? → Very slow at scale

**has_many :through:**
- Find posts with tag "Ruby"? → `Post.joins(:tags).where(tags: { name: "Ruby" })` (indexed, fast)
- List all tags? → `Tag.all` (separate table, O(1))
- Rename a tag? → `Tag.find_by(name: "Ruby").update(name: "Ruby Lang")` (1 row)
- Count posts per tag? → `Tag.joins(:posts).group(:name).count` (SQL GROUP BY, fast)

---

## 🧪 Quick Check

1. **In `has_many :tags, through: :post_tags` — what does `through` do?**
2. **Why does `post.tags << tag` NOT modify the posts table or the tags table?**
3. **`Post.joins(:tags).where(tags: { name: "Rails" })` — how many JOINs? Through which tables?**
4. **If User has_many :posts and Post has_many :tags through :post_tags — how do you find all tags for a user?**

**Discuss:** Think of real systems that use has_many :through — restaurant menu items? Students and courses? Users and roles?

---

## ✅ Before You Move On

- [ ] Can explain what a join table does and why it's needed
- [ ] Can read the SQL that ActiveRecord generates from has_many :through
- [ ] Understand that `through:` tells Rails which table to JOIN through
- [ ] Understand why JSON arrays don't scale
- [ ] Can name other places this pattern applies

---

## ➡️ Next: Branch `07-rich-text-images`

Plain text posts are boring — users want rich text and images. How many days of work do you think that takes? 😏
