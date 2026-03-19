---
branch: 10-day2-start
title: "Day 2 — Welcome Back"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 2
time: "9:30–10:00"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 09-erd-exercise
next: 11-turbo-frames
progress_file: ./progress.md
---

# Mentor Guide: 10-day2-start

## Teaching Goal

Get everyone oriented. Day 2 starts fresh — some students did Day 1, some didn't. The pre-built app levels the playing field. By the end of this 30 minutes, everyone should be able to explain the app from routes + schema.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Day 1 recap | 5 min | Quick — don't re-teach, just remind |
| Today's plan | 3 min | Show the schedule, set expectations |
| Setup | 7 min | git checkout, bundle, db:setup, bin/dev |
| Codebase reading exercise | 15 min | Routes + schema + models — NO controllers/views |

---

## Day 1 Recap (for facilitator)

Key concepts to remind:
- **Business → Database → Everything Else Follows**
- **Read the routes, know the database**
- **Business rules live in the model**
- **has_many :through = the one kick**
- **Tests pass ≠ no bugs**

Don't re-explain. Just list them. If someone missed Day 1, point them to the companion docs.

---

## For Day 1 Skippers

These students need extra context. Pair them with a Day 1 graduate. Key things they need to understand:
- OddlyHonest = social platform for sharing truths
- Published posts can't be edited
- Comments can't be edited
- has_many :through connects posts and tags via a join table
- Point them to `docs/06-tags-deep-dive/guide-th.md` during break

---

## UI Polish — What Changed

Students might ask "this looks different from yesterday." Explain:
- Same features, no new models or controllers
- Layout changed to centered Medium-style column
- Trix editor styled with custom CSS (sticky toolbar, serif font)
- Two Stimulus controllers added: notification (auto-dismiss) + confirm (custom modal)
- Tags show as pill badges, cover images as hero banners
- **This is what "polish" looks like — CSS + small JS behaviors**

---

## Checkpoint: Read the Codebase

**Ask:** "อ่าน routes.rb กับ schema.rb แล้วอธิบายแอปนี้"

**Expected answers:**
- Routes: posts, comments, tags, devise users
- Schema: posts (title, body, published, user_id), comments (body, post_id, user_id), tags (name), post_tags (post_id, tag_id), users (email, encrypted_password), action_text_rich_texts, active_storage_*
- Relationships: Post belongs_to User, Comment belongs_to Post + User, Post has_many Tags through PostTags

**If they can list this without reading any Ruby code — Day 1's lesson stuck.**

---

## Common Setup Issues

| Error | Fix |
|-------|-----|
| Database doesn't exist | `rails db:create db:migrate db:seed` |
| Missing gems | `bundle install` |
| Port 3000 in use | Kill other server or `bin/dev -p 3001` |
| Demo login doesn't work | `rails db:seed` to create demo user |

---

## Progress Logging

```markdown
## Branch 10-day2-start
### Orientation
- App running: [✅/❌]
- Demo login works: [✅/❌]
- Can explain app from routes + schema: [✅/❌]
- Day 1 attended: [yes/no]

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
