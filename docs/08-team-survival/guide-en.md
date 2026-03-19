---
branch: 08-team-survival
title: "Team Survival — Surviving in a Team"
lang: en
pair: guide-th.md
day: 1
time: "15:20–15:50"
duration: 30min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 07-rich-text-images
next: 09-erd-exercise
rails_guide: https://guides.rubyonrails.org/active_record_migrations.html
aha_moment: "Rails errors tell you exactly what's missing — read them"
business_rule: "Never edit someone else's migration. Always create a new one."
---

# Team Survival — Surviving in a Team

## The Business Question

You work in a team. Someone changes the schema, you pull, and now you get errors — what do you do?

This is a real situation that happens every day, in teams big and small. Once you know how to handle it, you will never fear migrations again.

---

## 1. Check Current State

Before doing anything, see where your database stands right now:

```bash
rails db:migrate:status
```

You will see a list of all migrations with their status — **UP** (already run) or **DOWN** (not yet run):

```
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20260319010000  Create users
   up     20260319020000  Create posts
   up     20260319030000  Create comments
```

If you see any **DOWN** entries, you have migrations that haven't been run yet — go ahead and run `rails db:migrate`.

---

## 2. Create a Practice Migration

Let's create a migration to add a new column:

```bash
rails g migration AddViewCountToPosts view_count:integer
```

Look at the generated file in `db/migrate/` — Rails creates it automatically. Then run:

```bash
rails db:migrate
```

Verify the column was added:

```bash
rails db:migrate:status
```

The new migration should show as **UP**.

---

## 3. Oops, Wrong Column! Rollback

Let's say we no longer want `view_count` — roll it back:

```bash
rails db:rollback
```

Check the status again and you will see the latest migration is now **DOWN**:

```bash
rails db:migrate:status
```

The `view_count` column is gone from the schema.

---

## 4. The Iron Rule: Never Edit Old Migrations

There are two scenarios:

### Scenario A: Not Pushed Yet (safe to edit)

If the migration exists only on your machine and has not been pushed to git:

1. `rails db:rollback` — undo the migration
2. Delete the wrong migration file
3. Create a new, correct migration
4. `rails db:migrate` again

### Scenario B: Already Pushed (never edit!)

If the migration has been pushed, your teammates may have already run it:

**Never edit it. Never delete it. Always create a new one.**

```bash
rails g migration RemoveViewCountFromPosts
```

Then write in the migration file:

```ruby
class RemoveViewCountFromPosts < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :view_count, :integer
  end
end
```

Then:

```bash
rails db:migrate
```

> **The golden rule: once pushed, never edit, never delete — always create a new migration.**

---

## 5. schema.rb Conflicts — Real Team Life

When two people create migrations at the same time and merge, `db/schema.rb` will conflict.

Why? Because `schema.rb` has a timestamp on the first line. Every time you run a migration, it gets updated.

**How to fix it:**

1. Accept either version of `schema.rb` (it doesn't matter which)
2. Run `rails db:migrate`
3. Rails will regenerate `schema.rb` correctly on its own
4. Commit the regenerated `schema.rb`

```bash
git checkout --theirs db/schema.rb   # or --ours, either works
rails db:migrate
git add db/schema.rb
git commit -m "Resolve schema.rb conflict"
```

Do not try to hand-edit `schema.rb` — let Rails handle it.

---

## Checkpoints

### Checkpoint 1 (Green)

What does `rails db:migrate:status` show?

> It shows a list of all migrations with their UP/DOWN status, telling you which migrations have been run and which have not.

### Checkpoint 2 (Yellow)

When can you delete a migration vs. when must you create a new one?

> You can delete a migration when it has not been pushed to git yet (it only exists on your machine). You must create a new migration when the original has already been pushed, because teammates may have already run it.

### Checkpoint 3 (Red)

A teammate pushes a migration that conflicts with yours. What do you do?

> 1. Pull their changes
> 2. Resolve the conflict in schema.rb (accept either version)
> 3. Run `rails db:migrate` — schema.rb will regenerate correctly
> 4. If your migration errors because a column already exists, rollback and create a new migration that does not conflict
> 5. Commit the clean schema.rb

---

## Summary

| Situation | Solution |
|---|---|
| Wrong migration, not pushed | rollback + delete + create new |
| Wrong migration, already pushed | create a new migration to fix it |
| schema.rb conflict | accept either + `rails db:migrate` |
| PendingMigrationError | `rails db:migrate` |

The **rollback -> fix -> migrate** cycle IS the normal workflow. It is not a failure — it is the process.

---

## Self-check

- [ ] I can run `rails db:migrate:status` and understand the output
- [ ] I have successfully rolled back and re-migrated
- [ ] I know when I can delete a migration vs. when I must create a new one
- [ ] I know how to resolve a schema.rb conflict

## Up Next

Next step: **09-erd-exercise** — we will draw the ERD for OddlyHonest to see the full picture of our data model.
