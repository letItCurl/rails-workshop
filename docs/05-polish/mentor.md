---
branch: 05-polish
title: "Polish — Validations + Honest UI"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "13:45–13:50"
duration: 5min
difficulty: 🟢 Recipe
prerequisite: 05-comments-authorization
next: 06-tags
aha_moment: "Defense in depth — 3 layers of protection"
progress_file: ./progress.md
---

# Mentor Guide: 05-polish

## Teaching Goal

Quick cleanup that reinforces defense in depth. Three layers: model validates data, controller checks authorization, view hides unavailable actions. Fast step — don't linger.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Show the problems | 1 min | Let them try creating empty post |
| Add validations | 2 min | Quick — just 3 lines |
| Hide buttons | 2 min | View conditionals |

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Existing seed posts now invalid | Seeds have no user | Update seeds or make user optional |
| `current_user` nil in view | Not logged in | Wrap in `if user_signed_in?` first |

---

## Progress Logging

```markdown
## Branch 05-polish
### Validations + UI
- Presence validations added: [✅/❌]
- Buttons hidden for non-owners: [✅/❌]

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
