---
branch: 06-tags-deep-dive
title: "Deep Dive — How has_many :through Actually Works"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "14:20–14:35"
duration: 15min
difficulty: 🟡 Recipe + Why
prerequisite: 06-tags
next: 07-rich-text-images
aha_moment: "Every ActiveRecord chain = readable SQL JOINs"
driving_force: "Fear of magic → there IS no magic, just SQL"
progress_file: ./progress.md
---

# Mentor Guide: 06-tags-deep-dive

## Teaching Goal

Students go from "it works" to "I understand exactly HOW it works." They can read the SQL, draw the tables, trace the JOINs, and see the pattern everywhere. This is the step that kills the "Rails magic" fear permanently.

**No new code.** This is 100% console exploration and conceptual understanding.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Table diagrams | 3 min | Draw on whiteboard or show the ASCII art |
| has_many arguments | 3 min | Line by line, each argument explained |
| Console SQL exploration | 5 min | Let them run each query and SEE the SQL |
| Chaining + comparison | 4 min | The "three JOINs" moment + JSON comparison |

**If behind:** Skip the JSON comparison. Never skip the console exploration.

---

## Checkpoint 1: through: argument

**Ask:** "`through: :post_tags` ทำอะไร?"

**Expected:** Tells Rails to find tags by going THROUGH the post_tags table. Rails generates a SQL JOIN from posts → post_tags → tags.

| Mistake | Response |
|---------|----------|
| "It connects them" | "HOW does it connect? What SQL does it generate?" |
| "It's like a shortcut" | "Yes — a shortcut through which table? What column does it use?" |

---

## Checkpoint 2: Why << doesn't touch posts or tags

**Ask:** "ทำไม `post.tags << tag` ไม่แก้ posts table?"

**Expected:** Because it only INSERTs a new row into post_tags. The connection lives in the join table, not in either of the main tables. Posts and tags never reference each other directly.

---

## Checkpoint 3: Count the JOINs

**Ask:** "`Post.joins(:tags).where(tags: { name: 'Rails' })` มีกี่ JOINs?"

**Expected:** Two JOINs: posts → post_tags (on post_id), post_tags → tags (on tag_id). Must go through post_tags because posts and tags have no direct connection.

**Follow-up:** "What about `User.joins(posts: :tags).where(tags: { name: 'Rails' })`?"

**Expected:** Three JOINs: users → posts → post_tags → tags.

---

## Checkpoint 4: Find user's tags

**Ask:** "User has_many :posts, Post has_many :tags through :post_tags — หา tags ทั้งหมดของ user ยังไง?"

**Expected:** `User.first.posts.includes(:tags).flat_map(&:tags).uniq` or using joins: `Tag.joins(posts: :user).where(users: { id: user.id }).distinct`

**If they struggle:** "Start from what you know: User.first.posts gives you posts. Each post has .tags. How do you collect all of them?"

---

## The Parallel with Existing Associations

Draw this on the whiteboard:

```
User → has_many :posts → has_many :comments (direct)
                       → has_many :tags, through: :post_tags

Same SQL pattern:
  User.first.posts      = SELECT * FROM posts WHERE user_id = 1
  post.comments         = SELECT * FROM comments WHERE post_id = X
  post.tags             = SELECT * FROM tags
                          JOIN post_tags ON tags.id = post_tags.tag_id
                          WHERE post_tags.post_id = X
```

The difference: comments have `post_id` directly (belongs_to). Tags go through a join table. But the ActiveRecord API looks the same: `post.comments` vs `post.tags`.

---

## If They Ask "Can't We Just Use has_and_belongs_to_many?"

Yes, Rails has `has_and_belongs_to_many` (HABTM) which skips the join model. But:
- You can't add extra columns to the join (e.g., `position`, `created_at`)
- You can't add validations to the join
- You can't query the join table directly
- `has_many :through` is more flexible and the community standard

**Short answer:** "has_many :through is always the right choice."

---

## Progress Logging

```markdown
## Branch 06-tags-deep-dive
### Checkpoint 1: through argument
- Explained JOIN through post_tags: [✅/❌]

### Checkpoint 2: Why << doesn't touch main tables
- Understood INSERT into post_tags only: [✅/❌]

### Checkpoint 3: Count JOINs
- Two JOINs correct: [✅/❌]
- Three JOINs (with user) correct: [✅/❌]

### Checkpoint 4: Find user's tags
- Found a working solution: [✅/❌]
- Method used: [chain/joins/other]

### Interaction Log

### Branch Summary
- started:
- finished:
- completed:
- total_questions:
- independence_score:
- understanding_score:
- curiosity_score:
```
