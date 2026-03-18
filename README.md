# OddlyHonest Workshop

A 2-day hands-on Ruby on Rails workshop. Build a social platform for sharing truths about life.

**Philosophy:** Business → Database → Everything Else Follows.

## Pre-work

1. Follow the setup guide: https://gorails.com/setup
2. Verify: `ruby -v` and `rails -v` work
3. PostgreSQL running locally, OR use Docker Compose:

```bash
docker compose up -d
```

## Workshop Structure

- **Day 1: "The One Kick"** — Build OddlyHonest from `rails new` to a full app
- **Day 2: "Turbo Day"** — Clone a pre-built repo, deep dive into Hotwire

## How to Follow Along

Each step is a git branch. Check out the branch for your current step:

```bash
git checkout 01-foundation
```

If you get stuck, check out the solution branch:

```bash
git checkout 01-foundation-final
```

To see what changed:

```bash
git diff 01-foundation..01-foundation-final
```

## Companion Docs

Each branch has companion docs in `docs/XX-branch-name/`:

- `guide-th.md` — Student guide (Thai)
- `guide-en.md` — Student guide (English)
- `mentor.md` — AI/Facilitator instructions
- `progress.md` — Assessment log

You can paste any guide into an AI (Claude, ChatGPT) and it will mentor you through the step.

## Day 1 Branches

| Branch | Time | Topic |
|--------|------|-------|
| `01-foundation` | 9:50–10:30 | rails new + scaffold |
| `02-posts` | 10:30–11:00 | Read routes, ORM transparency |
| `03-auth` | 11:15–11:45 | Devise authentication |
| `04-publish-rules` | 11:45–12:15 | Can't edit published posts + tests |
| `05-comments` | 13:15–13:50 | Comments, belongs_to, no edit |
| `06-tags` | 13:50–14:35 | has_many :through (the one kick) |
| `07-rich-text-images` | 14:50–15:20 | Action Text + Active Storage |
| `08-team-survival` | 15:20–15:50 | Migrations, rollbacks, git |
| `09-erd-exercise` | 15:50–16:30 | ERD modeling (5 problems) |

## Day 2 Branches

| Branch | Time | Topic |
|--------|------|-------|
| `10-turbo-frames` | 10:00–11:00 | Inline editing, no JS |
| `11-turbo-streams` | 11:15–12:15 | Real-time updates |
| `12-stimulus` | 13:15–13:45 | Small interactive JS |
| `13-hackathon` | 14:00–15:45 | Team hackathon |
| `14-deploy` | 16:00–16:15 | Kamal deploy (stretch) |
