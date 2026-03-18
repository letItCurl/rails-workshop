---
branch: 02-posts
title: "Posts — Read Routes, See SQL"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "10:30–11:00"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 01-foundation
next: 03-auth
rails_guide: https://guides.rubyonrails.org/routing.html
aha_moment: "The database IS the design — 2 files tell the whole story"
driving_force: "Fear of magic → show there's no magic, just SQL"
progress_file: ./progress.md
---

# Mentor Guide: 02-posts — Read Routes, See SQL

## How to Use This File

**Human facilitator:** This step is about understanding, not building. No new code. The whole point is: routes.rb + schema.rb = the entire app. Make them see it.

**AI mentor:** Respond in Thai by default. Don't let them skip the console exploration. They need to SEE the SQL with their own eyes.

---

## Teaching Goal

Students understand that Rails has no magic — ActiveRecord generates readable SQL. They can read any Rails app from 2 files: routes.rb and schema.rb. This kills the "magic is confusing" fear.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Read routes + routes.rb | 8 min | Make them count the routes |
| Read schema.rb | 5 min | Quick — it's just one table |
| Console SQL exploration | 12 min | THIS is the key moment — let them play |
| Quick check + discussion | 5 min | "Read the routes, know the database" |

**If behind:** Never skip the console exploration. That's where the aha happens.

---

## Checkpoint 1: Routes Count

**Ask:** "`resources :posts` สร้างกี่ routes?"

**Expected:** 7 routes (index, show, new, create, edit, update, destroy) — or 8 if they count the two update methods (PATCH + PUT)

| Mistake | Response |
|---------|----------|
| "I don't know" | "Run `rails routes` and count the lines with 'posts'" |
| Confuses routes with views | "Routes are URLs. Views are HTML files. How many URLs?" |

---

## Checkpoint 2: Predict SQL

**Ask:** "`Post.all` generate SQL อะไร?"

**Expected:** `SELECT "posts".* FROM "posts"`

**Follow-ups:**
- "Post.where(title: 'test') generate อะไร?" → `WHERE "posts"."title" = $1`
- "Post.first generate อะไร?" → `ORDER BY ... LIMIT 1`

| Mistake | Response |
|---------|----------|
| Can't predict | "Run it in console and watch the SQL output. Try again." |
| Says "I don't know SQL" | "You don't need to WRITE SQL. You need to READ it. What does SELECT * mean?" |

---

## Checkpoint 3: The Blueprint

**Ask:** "ถ้าต้องอ่าน Rails app ที่ไม่เคยเห็น เปิดไฟล์อะไรก่อน?"

**Expected:** `config/routes.rb` and `db/schema.rb`

**If they say "the README":** "Good instinct, but READMEs lie. Routes and schema are always up to date because they're generated from code."

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Console doesn't show SQL | Logger not set to debug | Check `config/environments/development.rb` — `config.log_level = :debug` |
| "Post.all returns empty" | No posts created yet | "Create one first: `Post.create(title: 'test', body: 'hello')`" |
| Console crashes on start | Spring cache issue | `bin/spring stop` then retry `rails console` |

---

## Aha Moment Setup

After the console exploration, pause and say:

> "ทุก method ที่คุณเรียก — Post.all, Post.where, Post.first — ActiveRecord แค่สร้าง SQL string แล้ว execute กับ database ไม่มี magic ซ่อนอยู่ อ่าน SQL ได้ = เข้าใจทุกอย่างที่ Rails ทำ"

Then ask: "ใน React/Next คุณเห็น query ที่วิ่งไป database มั้ย?"

---

## Progress Logging

```markdown
## Branch 02-posts
### Checkpoint 1: Routes Count
- Correct count (7): [✅/❌]

### Checkpoint 2: Predict SQL
- Post.all SQL correct: [✅/❌]
- Post.where SQL correct: [✅/❌]
- Post.first SQL correct: [✅/❌]

### Checkpoint 3: The Blueprint
- Named routes.rb + schema.rb: [✅/❌]

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
