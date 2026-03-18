---
branch: 00-start
title: "Getting Started — Pre-Workshop Setup"
lang: en
pair: guide-th.md
day: 0
difficulty: "🟢 Recipe"
next: 01-foundation
---

# Getting Started — Pre-Workshop Setup

## Welcome to the OddlyHonest Workshop!

This workshop will walk you through building a real web app with Ruby on Rails from start to finish.

## Why Rails?

You probably already use React or Next.js, and that's great. But think about it — every time you start a new project, you have to wire everything up yourself: authentication, database, API routes, form handling, validation...

What if a framework handled 80% of that for you? So you could focus on actual business logic instead of sitting around setting up boilerplate.

That's Rails.

## Setup Steps

### 1. Install Ruby and Rails

Follow the instructions at [gorails.com/setup](https://gorails.com/setup) for your OS (macOS, Ubuntu, Windows).

The guide walks you through everything from a Ruby version manager all the way to Rails itself.

### 2. Verify Ruby

```bash
ruby -v
```

You should see version 3.2 or higher.

### 3. Verify Rails

```bash
rails -v
```

You should see version 7.1 or higher.

### 4. Verify PostgreSQL

Pick one of these approaches:

**Option A: Installed locally**

```bash
psql --version
psql -U postgres -c "SELECT 1;"
```

**Option B: Using Docker Compose**

```bash
docker compose up -d db
docker compose exec db psql -U postgres -c "SELECT 1;"
```

If you get a result back with no errors, PostgreSQL is ready to go.

## Checklist

Before the workshop, make sure you can check off every item:

- [ ] Ruby installed (version 3.2+)
- [ ] Rails installed (version 7.1+)
- [ ] PostgreSQL working (native or Docker)
- [ ] Repo cloned
- [ ] Editor ready (VS Code, RubyMine, etc.)

## What's Next

Once your setup is complete, we'll kick things off with **01-foundation**, where we build the first structure of the app together. Get everything ready and we'll see you on the day!
