---
role: mentor
guides:
  - guide-th.md
  - guide-en.md
progress_file: ./progress.md
---

# Mentor / Facilitator Instructions — 00-start

## How to Use This Step

1. **Human facilitator** sends the student guide (Thai or English) to participants **at least 1 week before** the workshop.
2. **AI mentor** can help participants verify their setup interactively — walk them through each checkpoint and troubleshoot issues in real time.

The goal is simple: everyone should arrive on day 1 with a working environment. No one should spend workshop time installing Ruby.

## Teaching Goal

> Students arrive with Ruby, Rails, PostgreSQL, and the repo all working on their machine. Zero setup on workshop day.

## Checkpoints

### Checkpoint 1: Ruby Installed

**Command:**

```bash
ruby -v
```

**Expected output:**

```
ruby 3.2.x (or higher)
```

| Common Error | Cause | Fix |
|---|---|---|
| `command not found: ruby` | Ruby not installed or not in PATH | Follow gorails.com/setup from scratch |
| Version below 3.2 | Old system Ruby | Install via rbenv or asdf, not system package manager |
| `rbenv: version not installed` | Version listed in `.ruby-version` not installed | Run `rbenv install` then `rbenv rehash` |

### Checkpoint 2: Rails Installed

**Command:**

```bash
rails -v
```

**Expected output:**

```
Rails 7.1.x (or higher)
```

| Common Error | Cause | Fix |
|---|---|---|
| `command not found: rails` | Gem not installed | Run `gem install rails` |
| Bundler version conflict | Mismatched bundler | Run `gem install bundler` then retry |
| Permission denied | Using system Ruby without sudo | Switch to rbenv/asdf-managed Ruby |

### Checkpoint 3: PostgreSQL Running

**Command (native):**

```bash
psql -U postgres -c "SELECT 1;"
```

**Command (Docker):**

```bash
docker compose up -d db
docker compose exec db psql -U postgres -c "SELECT 1;"
```

**Expected output:**

```
 ?column?
----------
        1
(1 row)
```

| Common Error | Cause | Fix |
|---|---|---|
| `connection refused` | PostgreSQL service not running | `brew services start postgresql` or `docker compose up -d db` |
| `role "postgres" does not exist` | macOS Homebrew default uses current user | `createuser -s postgres` or connect with your username |
| `docker: command not found` | Docker not installed | Install Docker Desktop |
| Port 5432 already in use | Another PostgreSQL instance running | Stop the other instance or change port |

### Checkpoint 4: Repo Cloned

**Command:**

```bash
cd rails-workshop && git status
```

**Expected output:**

```
On branch 00-start
nothing to commit, working tree clean
```

| Common Error | Cause | Fix |
|---|---|---|
| `not a git repository` | Not in the right directory | Clone the repo again |
| Wrong branch | Checked out a different branch | Run `git checkout 00-start` |
| SSH permission denied | SSH key not configured for GitHub | Use HTTPS clone URL or add SSH key |

## If Everything Goes Wrong

Sometimes a participant's machine just won't cooperate — ancient OS, corporate firewall, disk space issues. Don't let setup block learning.

- **Pair up.** Have them sit with someone whose setup works and share a screen.
- **Use a cloud environment.** GitHub Codespaces or Gitpod can get a working environment in minutes.
- **Move on.** It's better to start learning with a borrowed setup than to spend the whole morning debugging PATH variables.

The worst outcome is someone feeling discouraged before the workshop even begins. Prevent that.

## Progress Logging Format

After verifying each participant's setup, record results in `progress.md` using this format:

```yaml
student: "<name>"
group: "<group>"
date: "<YYYY-MM-DD>"
```

For each checkpoint, mark as:
- `pass` — working correctly
- `fail` — not working, with a note on the issue
- `skip` — not verified yet

Include total setup time and any issues encountered so the team can improve the setup guide over time.
