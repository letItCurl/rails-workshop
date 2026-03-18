---
role: mentor
guides:
  - guide-th.md
  - guide-en.md
aha_moment: "3 commands = working app"
driving_force: "See what Rails gives for free vs hours of manual wiring"
progress_file: ./progress.md
---

# Mentor Guide — 01-foundation

## Teaching Goal

This is the **hook**. Students should experience the raw speed of Rails — going from zero to a fully working CRUD app in minutes. The aha moment is the contrast: "3 commands, and it works. In React, how long would this take?"

Don't over-explain. Let them feel the speed first, understand the structure second.

---

## Timing Guide (40 minutes total)

### Section 1 — Context & Setup (10 min)

- Open with the React/Next comparison question
- Let students answer — get them talking about their past pain points
- Run `rails new . -d postgresql --css tailwind --name oddly_honest` together
- While it runs, briefly explain what's being generated

### Section 2 — Database & Scaffold (10 min)

- Run `rails db:create`
- Run `rails g scaffold Post title:string body:text`
- Walk through the output — point out each file generated
- Don't deep-dive into any file yet, just show the list

### Section 3 — Migrate & Run (10 min)

- Run `rails db:migrate`
- Run `bin/dev`
- Let students open localhost:3000/posts
- Have them create, edit, and delete a post
- Let them play — this is the aha moment

### Section 4 — Checkpoints & Reflection (10 min)

- Run through the 3 checkpoint questions
- Open `config/routes.rb` together
- Run `rails routes` to show all 7 generated routes
- Quick self-check review
- Tease 02-posts

---

## Checkpoints

### Checkpoint 1: It Works

**Question:** Can you see the posts page at localhost:3000/posts?

**Expected Answer:** Yes — the page loads and shows an empty list with a "New post" link.

| Error | Cause | Fix |
|---|---|---|
| `PG::ConnectionBad` | PostgreSQL is not running | `brew services start postgresql` or `sudo systemctl start postgresql` |
| `ActiveRecord::NoDatabaseError` | Forgot `rails db:create` | Run `rails db:create` |
| `ActiveRecord::PendingMigrationError` | Forgot `rails db:migrate` | Run `rails db:migrate` |
| Port 3000 in use | Another server is running on 3000 | Kill the other process: `lsof -i :3000` then `kill -9 <PID>`, or use `bin/dev -p 3001` |

### Checkpoint 2: Count the Commands

**Question:** From zero to a working app, how many commands did it take?

**Expected Answer:** 3 core commands — `rails new`, `rails g scaffold`, `rails db:migrate`. (Accepting 4-5 if they count `db:create` and `bin/dev` is fine — the point is it's shockingly few.)

| Common Mistake | Redirect |
|---|---|
| Student says "1" | They're only counting `rails new` — ask what created the posts table |
| Student says "10+" | They're counting sub-steps — focus on terminal commands actually typed |

### Checkpoint 3: Scaffold Files

**Question:** What's in `config/routes.rb`?

**Expected Answer:** `resources :posts` — a single line that generates all 7 RESTful routes.

| Common Mistake | Redirect |
|---|---|
| Student doesn't open the file | Have them open it in their editor — reading code is a habit to build early |
| Student doesn't understand `resources` | Run `rails routes` together and map each route to a controller action |

---

## Aha Moment Setup

The key line to land:

> **"3 คำสั่ง แอปทำงานได้ครบ ใน React ใช้เวลาเท่าไหร่?"**
> ("3 commands, the app fully works. In React, how long would this take?")

Let students answer. Don't rush past this. The contrast is the lesson.

---

## Common Mistakes

| Mistake | What Happens | How to Help |
|---|---|---|
| Skipped `rails db:create` | `ActiveRecord::NoDatabaseError` on first request | Run `rails db:create` then `rails db:migrate` |
| Skipped `rails db:migrate` | `ActiveRecord::PendingMigrationError` on first request | Run `rails db:migrate` |
| Ran `rails server` instead of `bin/dev` | Tailwind CSS doesn't compile, app looks unstyled | Stop server, use `bin/dev` instead |
| PostgreSQL not running | `PG::ConnectionBad` | Start PostgreSQL service |
| Typo in scaffold command | Wrong column names or types | Run `rails destroy scaffold Post` and redo |
| Ran `rails new` in non-empty directory | Conflicts with existing files | Use `--force` flag or start in a clean directory |

---

## Progress Logging

After the session, fill in `progress.md` for each student/pair using this format:

### Interaction Log

Record notable moments during the session:

```
- [timestamp] observation or question from student
- [timestamp] intervention or hint given
```

### Branch Summary

```yaml
started: "HH:MM"
finished: "HH:MM"
completed: true/false
total_questions: 0
independence_score: 0-5    # 5 = completed with no help
understanding_score: 0-5   # 5 = could explain every step
curiosity_score: 0-5       # 5 = asked questions beyond the guide
```
