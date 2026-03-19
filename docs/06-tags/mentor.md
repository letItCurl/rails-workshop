---
role: mentor
branch: 06-tags
title: "Tags — has_many :through (Mentor Guide)"
aha_moment: "has_many :through — two lines handle everything"
driving_force: "Fear of magic -> understand WHY conventions exist"
progress_file: ./progress.md
---

# Mentor Guide: 06-tags (has_many :through)

## Teaching Goal

Master join tables = master data modeling. This is THE transferable skill from this entire workshop. Whether students continue with Rails, switch to Django, use Prisma with Node, or design a GraphQL schema — understanding many-to-many relationships through join tables is fundamental. Every framework has its own syntax, but the data modeling concept is universal.

This is the "one kick" step. Don't rush it.

---

## Timing Guide (45 minutes total)

| Section | Time | Minutes | Notes |
|---------|------|---------|-------|
| Business question + paper drawing | 13:50–13:58 | 8 min | Let them draw. Resist the urge to show the answer. |
| Why join table + scaffold + migration | 13:58–14:10 | 12 min | Show schema.rb after each migration. |
| Wire models + console exploration | 14:10–14:22 | 12 min | **Do not rush this.** Let students type every command. Watch the SQL output together. |
| Checkpoint 1 + Form + Badges | 14:22–14:32 | 10 min | Checkpoint 1 should be quick. Form is recipe-follow. |
| Checkpoints 2 & 3 + Reflection | 14:32–14:35 | 3 min | CP3 can be homework if time is tight. Reflection can happen during break. |

**Key timing rule:** If you have to cut something, cut the form/badges (students can do that as recipe-follow). Never cut the console exploration or Checkpoint 1 — those are where understanding happens.

---

## Checkpoint 1 (Green) — Expected Answers

**Question 1: What columns does `post_tags` have?**

Expected answer: `id`, `post_id`, `tag_id`, `created_at`, `updated_at`

| Common Mistake | How to Redirect |
|---------------|-----------------|
| Forgets `id` | "What does every Rails table have by default?" |
| Adds `name` or other columns | "This table only connects — it doesn't own any data. Where does the tag name live?" |
| Says only `post_id` and `tag_id` | Acceptable — nudge about id and timestamps but don't penalize |

**Question 2: Why a separate table? Why not store directly in Post?**

Expected answer: A single column can't hold a proper many-to-many relationship. JSON arrays can't be queried efficiently, can't be indexed, and can't enforce referential integrity. A separate table lets the database do what it does best — join normalized data.

| Common Mistake | How to Redirect |
|---------------|-----------------|
| "Because Rails says so" | "Forget Rails. If you were using raw SQL, how would you connect posts and tags?" |
| "JSON works fine" | "How would you find all posts tagged 'Rails'? How would you rename 'Rails' to 'Ruby on Rails' across all posts?" |

**Question 3: If a post has 3 tags, how many rows in `post_tags`?**

Expected answer: 3

| Common Mistake | How to Redirect |
|---------------|-----------------|
| Says 1 | "Each connection is one row. Draw it out — post_id 1 + tag_id 1, post_id 1 + tag_id 2, ..." |
| Says 6 | "That would mean each tag also creates a reverse row. The join table is directionless — one row serves both directions." |

---

## Checkpoint 2 (Yellow) — Expected SQL

```sql
SELECT posts.*
FROM posts
INNER JOIN post_tags ON post_tags.post_id = posts.id
INNER JOIN tags ON tags.id = post_tags.tag_id
WHERE tags.name = 'Rails'
```

The key insight: there are **two JOINs** — `posts -> post_tags -> tags`. The `post_tags` table sits in the middle.

| Common Mistake | How to Redirect |
|---------------|-----------------|
| Writes only one JOIN (posts directly to tags) | "How does the database know which posts connect to which tags? There's no tag_id on posts." |
| Forgets post_tags entirely | "What table sits between posts and tags? That's the bridge." |
| Gets the ON clauses backwards | "Read it out loud: post_tags.post_id equals posts.id — does that make sense directionally?" |

---

## Checkpoint 3 (Red) — Expected Test

```ruby
require "test_helper"

class PostTagAssociationTest < ActiveSupport::TestCase
  test "post and tag are associated bidirectionally" do
    user = User.create!(email: "test@example.com", password: "password")
    post = Post.create!(title: "Test Post", body: "Some body text", user: user)
    tag = Tag.create!(name: "Rails")

    post.tags << tag

    assert_includes post.tags, tag
    assert_includes tag.posts, post
  end
end
```

**Hint escalation (give one at a time, wait 2 minutes between):**

1. "You need a user first — posts belong to users, remember step 04."
2. "Use `post.tags << tag` to create the connection. Then assert both directions."
3. "The two key assertions are `assert_includes post.tags, tag` and `assert_includes tag.posts, post`."

| Common Mistake | How to Redirect |
|---------------|-----------------|
| Forgets to create a User for the Post | "Post belongs_to :user — what happens if you skip it?" |
| Uses `post.tag = tag` (singular) | "It's a has_many — plural. `post.tags << tag`" |
| Doesn't test reverse direction | "You proved post knows its tags. Does the tag know its posts?" |
| Test fails with validation error | "Check what validations Post has. Does it need a title? A body? A user?" |

---

## Common Errors Table

| Error | Cause | Fix |
|-------|-------|-----|
| `NoMethodError: undefined method 'tags' for Post` | Forgot `has_many :tags, through: :post_tags` in Post model | Add the two has_many lines to Post |
| `PG::UndefinedTable: post_tags` | Forgot to run migration | `rails db:migrate` |
| `ActiveModel::UnknownAttributeError: tag_ids` | Using `tag_ids` without the association | Ensure `has_many :tags, through: :post_tags` is in Post |
| `Unpermitted parameter: :tag_ids` | Permitted as scalar instead of array | Change to `tag_ids: []` in strong params |
| Tags don't save from form | Missing `tag_ids: []` in permit | Add `tag_ids: []` at the end of the permit list |
| `ActiveRecord::RecordInvalid` on PostTag | Missing belongs_to in PostTag model | Ensure `belongs_to :post` and `belongs_to :tag` exist |
| Tags display but can't be removed | Unchecking doesn't send empty array | `collection_check_boxes` handles this with a hidden field — check form HTML |

---

## Aha Moment Setup

After the console exploration (section 6), pause and say:

> "Look at what just happened. You wrote two lines in Post, two lines in Tag, and Rails handles the entire SQL JOIN — creating connections, querying through them, even deleting them. **Two lines handle everything.**"

Then ask: "Where else would you use this?" Let them brainstorm. Guide toward:
- Student and Course (enrollments)
- Order and Product (order_items — note this join table has extra data like quantity!)
- User and Role (user_roles)
- In their world: User and Project, Developer and Skill, any many-to-many

The `order_items` example is especially powerful because it shows that join tables can carry their own data (quantity, price_at_purchase) — they're not always empty connectors.

---

## If Everything Goes Wrong

If students are lost and code isn't working:

1. **Stop coding.** Close all laptops.
2. **Go to the whiteboard.** Draw three tables as boxes:

```
+--------+     +-----------+     +------+
| posts  |     | post_tags |     | tags |
+--------+     +-----------+     +------+
| id     |<----| post_id   |     | id   |
| title  |     | tag_id    |---->| name |
| body   |     +-----------+     +------+
+--------+
```

3. **Fill in real data:**

```
posts:        post_tags:        tags:
id | title    post_id | tag_id  id | name
1  | "My App" 1       | 1       1  | "Rails"
2  | "TDD"    1       | 2       2  | "Ruby"
             2       | 1       3  | "Testing"
             2       | 3
```

4. **Trace the query:** "Find all tags for post 1" — follow the arrows. post_id=1 in post_tags gives us tag_id 1 and 2. Look those up in tags: "Rails" and "Ruby."

5. **Then go back to code.** The model lines are just telling Rails what you drew on the board.

---

## Progress Logging

Use `progress.md` in this directory to track each student's progress. Log format:

```markdown
### [Student Name]
- **CP1 (Green):** [Pass/Fail] — [notes on which questions they got right/wrong]
- **CP2 (Yellow):** [Pass/Fail] — [did they get the double JOIN? how close was their SQL?]
- **CP3 (Red):** [Pass/Fail] — [hints used: 0/1/2/3] — [notes]
- **Interaction Log:** [key moments, questions asked, breakthroughs]
- **Branch:** [confirmed pushed / needs help]
```

This is the step where you learn the most about each student's data modeling intuition. Pay attention to who "gets it" at the whiteboard vs. who needs the code to understand. Neither is wrong — but it tells you how to teach them in later steps.
