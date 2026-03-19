---
role: mentor
title: "Hackathon — Mentor Guide"
---

# Hackathon — Mentor Guide

## Timing

| Phase | Duration | Time |
|-------|----------|------|
| Setup (teams + ERD) | 15 min | 13:45–14:00 |
| Build | 90 min | 14:00–15:30 |
| Demos | 15 min | 15:30–15:45 |
| Buffer / retro | 15 min | 15:45–16:00 |

---

## Setup Phase (15 min)

1. Help students form teams of 3–4, mixing experience levels
2. Each team picks one feature from the menu
3. Teams draw their ERD on paper (whiteboard or A4)

### CRITICAL: Check ERDs Before Coding Starts

- **No team writes a single line of code until you have checked their ERD**
- Look for: correct table names, foreign keys, polymorphic columns (`_type` + `_id`), join tables
- Ask: "What happens when a user is deleted?" — do they have `dependent: :destroy`?
- If the ERD is wrong, ask a question that leads them to the fix — do not fix it for them

---

## Build Phase (90 min)

### Facilitation Style

- **Walk around constantly** — do not sit at your own laptop
- **Answer with questions, not answers** — "What does the error message say?" / "What did you expect to happen?"
- **Watch for teams stuck >15 minutes** — if a team has made zero progress for 15 minutes, give them ONE hint:
  - Point them to the right section of the feature doc
  - Suggest they re-read the error message carefully
  - Ask them to explain their approach out loud (rubber duck)
- Do NOT write code for them
- Do NOT pair-program unless a team is truly lost with <30 min remaining

### Common Pitfalls to Watch For

- Forgetting to run `rails db:migrate`
- Polymorphic: missing `_type` column or wrong `as:` name
- `has_many :through`: forgetting the intermediate `has_many`
- Turbo Streams: broadcasting to wrong stream name
- Active Storage: forgetting `has_one_attached` or missing `permit` in controller

---

## Demo Phase (15 min)

### Format: 3 minutes per team

1. **Show the ERD** — hold up the paper, explain the tables and relationships
2. **Show the code** — walk through the key model/controller/view changes
3. **Run the test** — execute the test suite live; the feature is not done until the test passes
4. Applaud every team regardless of completion level

### If a test fails during demo

- That is okay — it is a learning moment
- Ask: "What do you think went wrong?"
- The team can fix it during the buffer phase

---

## Buffer Phase (15 min)

- Teams that failed their demo test can attempt a fix
- Quick retro: "What was the hardest part?" — go around the room
- Celebrate wins, acknowledge struggles
- Transition to the next session (deploy)
