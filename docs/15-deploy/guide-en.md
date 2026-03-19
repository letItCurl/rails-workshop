---
branch: 15-deploy
title: "Deploy — Your App Is on the Internet"
lang: en
pair: guide-th.md
day: 2
time: "16:00–16:15"
duration: 15min
difficulty: 🟢 Recipe
prerequisite: 14-hackathon
next: null
aha_moment: "From rails new to production in 2 days"
business_rule: "Stretch goal — if VM is available"
---

# 🚀 Deploy — 3 Commands, Goodbye

Last 15 minutes. The app you built over 2 days is about to be on the internet.

**No Docker explanation. No Kamal explanation. No DevOps theory. Just follow the steps and it works.**

---

## Prep

Your VM is ready at: `your-team.oddlyhonest.dev`

Verify SSH works:

```bash
ssh deploy@your-team.oddlyhonest.dev "echo connected"
```

---

## Deploy

### Step 1: Configure

Open `config/deploy.yml` and edit:

```yaml
service: oddly-honest
image: your-team/oddly-honest

servers:
  web:
    hosts:
      - your-team.oddlyhonest.dev
    options:
      network: "host"

proxy:
  ssl: true
  host: your-team.oddlyhonest.dev

registry:
  server: ghcr.io
  username: your-github-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
```

### Step 2: Setup

```bash
kamal setup
```

Wait... Docker install, image build, push, pull, start — all automatic.

### Step 3: Deploy

```bash
kamal deploy
```

---

## Open Your Browser

Go to `https://your-team.oddlyhonest.dev`

**Your app is on the internet.** From `rails new` to production in 2 days.

---

## 🎉 That's a Wrap

You started with "Why Rails?" Now you can:

- Build an app from scratch
- Think database-first
- Write business rules + tests
- Master has_many :through
- Use Turbo Frames + Streams (zero JS)
- Build Stimulus controllers
- Build features independently in a hackathon
- Deploy to production

**The skill AI can't replace: understand the problem → model the database → everything else follows.**

Thank you 🙏
