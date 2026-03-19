---
role: mentor
step: 08-team-survival
aha_moment: "Errors tell you exactly what's missing — read them"
driving_force: "Fear of magic → errors are teachers"
---

# Mentor Guide — Team Survival

## Teaching Goal

Students can handle real team workflow: rollback, fix, migrate. They stop fearing errors and start reading them as helpful messages. By the end of this step, the rollback-fix-migrate cycle should feel like a normal, comfortable workflow — not an emergency procedure.

---

## Timing Guide (30 minutes)

| Time | Section | Minutes | Focus |
|---|---|---|---|
| 15:20–15:27 | Check state + create migration | 7 | `db:migrate:status`, generate and run a practice migration |
| 15:27–15:34 | Rollback + the golden rule | 7 | `db:rollback`, when to delete vs. create new migration |
| 15:34–15:44 | schema.rb conflict simulation | 10 | Walk through the conflict scenario, demonstrate the fix |
| 15:44–15:50 | Checkpoints + wrap-up | 6 | Verify understanding, answer questions |

---

## Checkpoints with Expected Answers

### Checkpoint 1 (Green) — "What does `rails db:migrate:status` show?"

**Expected answer:** A list of all migrations with UP/DOWN status. UP means the migration has been run, DOWN means it has not.

**If they struggle:** Have them run the command and read the output together. Point at a specific line and ask "is this one run or not?"

### Checkpoint 2 (Yellow) — "When can you delete a migration vs. when must you create a new one?"

**Expected answer:** Delete only if the migration has NOT been pushed to git (exists only locally). Create a new one if it has been pushed, because teammates may have already run it.

**If they struggle:** Use the analogy: "If you sent an email, you can't unsend it. You send a correction email instead."

### Checkpoint 3 (Red) — "A teammate pushes a conflicting migration. What do you do?"

**Expected answer:** Pull, accept either version of schema.rb, run `rails db:migrate` to regenerate schema.rb, resolve any column-exists errors with a new migration, then commit.

**If they struggle:** Walk through it step by step on screen. This is the hardest concept — it is okay to spend extra time here.

---

## Common Errors Table

| Error | Cause | Fix |
|---|---|---|
| `ActiveRecord::PendingMigrationError` | There are migrations that have not been run | `rails db:migrate` |
| "Migration XXXXX has already been run" | Trying to re-run an already-UP migration | Check `db:migrate:status` — the migration is already applied. No action needed. |
| schema.rb conflict (git merge conflict) | Two people created migrations and both modified schema.rb | Accept either version of schema.rb, then run `rails db:migrate`. It regenerates automatically. |
| `PG::DuplicateTable` or "relation already exists" | A migration tries to create a table/column that already exists | Rollback if local-only, or create a new migration that checks `if table_exists?` / `if column_exists?` |
| "No migration with version number XXXXX" | A migration file was deleted but the database still has a record of it | If local-only: `rails db:migrate:status` to find the ghost, then manually clean `schema_migrations` table. Avoid this situation by following the golden rule. |

---

## Key Teaching Moment

The **rollback -> fix -> migrate** cycle IS the workflow. Emphasize this repeatedly.

Students often feel like rolling back means they "messed up." Reframe it: this is the normal development loop. Professional Rails developers rollback dozens of times a week. It is not a failure state — it is the process.

When an error appears, the instinct is to panic. Train them to **read the error message first**. Rails errors are remarkably clear. `PendingMigrationError` literally tells you to run migrations. "Relation already exists" tells you the table is already there. The error IS the documentation.

---

## Teaching Tips

- **Live demo over slides.** Create a migration, run it, rollback it, delete it, create a new one — all live. Let them see the rhythm.
- **Let them hit the error.** Do not prevent the error. Let `PendingMigrationError` appear, then ask "what does the error say to do?" They will read it and know.
- **Pair exercise for schema conflict.** If time allows, have two students create migrations on separate branches and merge. Let the conflict happen naturally.
- **Repeat the golden rule.** Say it multiple times: "If pushed, never edit, never delete, always create new." Repetition makes it stick.

---

## Watch For

- Students editing migration files that have already been run (without rolling back first) — this causes silent schema drift
- Students manually editing `schema.rb` — this should never be done; always let Rails regenerate it
- Students confusing `db:rollback` (undo last migration) with `db:reset` (drop + recreate entire database) — make sure they know the difference
- Fear paralysis: some students will be afraid to run any migration command. Remind them that `db:rollback` exists and nothing is permanent
