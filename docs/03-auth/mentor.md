---
branch: 03-auth
title: "Auth — Who Posted This?"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "11:15–11:45"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 02-posts
next: 04-publish-rules
rails_guide: https://guides.rubyonrails.org/security.html
aha_moment: "Auth in 3 commands — what took weeks before"
driving_force: "See what Rails gives for free (auth in 3 commands)"
progress_file: ./progress.md
---

# Mentor Guide: 03-auth — Who Posted This?

## Teaching Goal

Students see that auth — the thing that takes weeks in their current stack — is 3 commands in Rails. They understand belongs_to/has_many as database relationships, not abstract concepts.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Install Devise | 8 min | bundle add + generate + migrate |
| Wire User to Post | 8 min | Migration + belongs_to + has_many |
| Lock down controller | 7 min | before_action + current_user.posts.build |
| Test + checkpoints | 7 min | Browser test + discussion |

**If behind:** Skip the checkpoint discussion but NEVER skip the browser test (seeing login redirect).

---

## Checkpoint 1: belongs_to Meaning

**Ask:** "`belongs_to :user` ใน Post หมายความว่าอะไร?"

**Expected:** Post cannot exist without a User. There's a `user_id` foreign key in the posts table pointing to users.

| Mistake | Response |
|---------|----------|
| "It means they're connected" | "How? What column in the database makes this connection?" |
| Confuses with has_many | "belongs_to is the side that HAS the foreign key. Which table has user_id?" |

---

## Checkpoint 2: dependent :destroy

**Ask:** "ถ้าลบ User — โพสต์จะเป็นยังไง?"

**Expected:** All their posts get destroyed too (because of `dependent: :destroy`).

**Follow-up:** "What if we used `dependent: :nullify` instead?" → user_id becomes nil, posts remain.

---

## Checkpoint 3: before_action

**Ask:** "`before_action :authenticate_user!, except: [:index, :show]` ทำอะไร?"

**Expected:** Requires login for all actions EXCEPT viewing the list (index) and viewing a single post (show). Creating, editing, deleting require login.

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Devise::MissingWarden` | Forgot `rails g devise:install` | Run the install generator |
| `NOT NULL violation: user_id` | Existing posts have no user_id | `rails db:reset` or set nullable: `change_column_null :posts, :user_id, true` |
| `undefined method 'current_user'` | Devise not fully installed | Check `devise_for :users` in routes.rb |
| Login page unstyled | Normal — Devise views are bare | Can customize later, not important now |

---

## Aha Moment Setup

After they see the login redirect in the browser:

> "3 คำสั่ง — bundle add devise, rails g devise:install, rails g devise User — ได้ signup, login, logout, forgot password, session management ทั้งหมด ในโปรเจคที่แล้วใช้เวลาเท่าไหร่?"

---

## Progress Logging

```markdown
## Branch 03-auth
### Checkpoint 1: belongs_to Meaning
- Explained correctly: [✅/❌]
- Mentioned foreign key: [✅/❌]

### Checkpoint 2: dependent :destroy
- Correct answer: [✅/❌]
- Knew about :nullify alternative: [✅/❌]

### Checkpoint 3: before_action
- Explained except clause: [✅/❌]

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
