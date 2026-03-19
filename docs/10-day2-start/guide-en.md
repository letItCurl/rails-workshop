---
branch: 10-day2-start
title: "Day 2 — Welcome Back"
lang: en
pair: guide-th.md
day: 2
time: "9:30–10:00"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 09-erd-exercise
next: 11-turbo-frames
---

# ☀️ Day 2 — Welcome Back

What did you do yesterday? Think about it:

- Built an app from `rails new` — 3 commands, full CRUD
- Read routes + schema and understood the whole app from 2 files
- Added auth with Devise — 3 commands, signup/login/logout
- Wrote business rules in the model — published posts can't be edited
- Wrote tests BEFORE code — fail first, then pass
- Discovered that passing tests ≠ no bugs (authorization)
- Scaffolded comments then **removed** edit — a business decision
- Mastered has_many :through with join tables — the one kick
- Saw the actual SQL that ActiveRecord generates — no magic
- Added rich text + images — zero custom code
- Survived migration conflicts
- Modeled 5 businesses as ERDs — the transferable skill

**All of that in one day.**

---

## What's Today?

Today is **Turbo Day** — you'll discover that Rails handles the frontend too, with **zero JavaScript written**.

Yesterday you built a solid backend. Today you'll make it interactive:

| Time | What you'll do | Aha moment |
|------|---------------|-----------|
| 9:30–10:00 | Read the codebase | "I can read any Rails app from routes + schema" |
| 10:00–11:00 | Turbo Frames | "Inline editing with zero JS" |
| 11:15–12:15 | Turbo Streams | "Real-time updates — 2 lines of code" |
| 13:15–13:45 | Stimulus | "This is ALL the JS I need" |
| 14:00–15:45 | Hackathon | "I did Business → DB → Code independently" |
| 16:00–16:15 | Deploy (stretch) | "My app is on the internet" |

---

## The App You're Looking At

The app you see is OddlyHonest — same as what you built yesterday, but with polished UI:

- **Layout:** Centered column like Medium
- **Typography:** Georgia serif for content
- **Trix editor:** Styled toolbar, sticky, wrapping
- **Notifications:** Auto-dismiss after 3 seconds
- **Confirm dialog:** Custom modal instead of browser default
- **Tags:** Pill badges
- **Cover images:** Full-width hero

**Everything added is CSS + 2 Stimulus controllers.** No new features, just polish.

---

## Getting Started

```bash
git checkout 10-day2-start
bundle install
rails db:setup
bin/dev
```

Open http://localhost:3000 — login with `demo@oddlyhonest.com` / `password`

---

## 🔍 Read the Codebase

Before writing any code — **read first.**

1. **Open `config/routes.rb`** — what resources exist?
2. **Open `db/schema.rb`** — how many tables? What are the relationships?
3. **Open models** (`app/models/`) — read the associations and validations
4. **Don't read controllers or views yet**

**Ask your group:** Explain this app to your neighbor using only routes + schema.

---

## For Those Who Missed Day 1

No worries! The app is ready — you don't need to build it.

What you need to know:
- **Post** has title, rich text body, cover image, published flag, tags
- **Comment** belongs_to Post + User, can never be edited
- **Tag** connects to Post via PostTag (has_many :through)
- **User** uses Devise (signup/login/logout)
- Only the owner can edit/delete their own content

To understand has_many :through deeper, read `docs/06-tags-deep-dive/guide-en.md`

---

## ✅ Before You Move On

- [ ] App runs at localhost:3000
- [ ] Can login with demo account
- [ ] Read routes.rb and can list all resources
- [ ] Read schema.rb and can count all tables
- [ ] Can explain the relationships between models

---

## ➡️ Next: Branch `11-turbo-frames`

You want to edit a post inline — no page reload. How? Without writing any JavaScript.
