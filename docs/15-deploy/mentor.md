---
branch: 15-deploy
title: "Deploy — Your App Is on the Internet"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 2
time: "16:00–16:15"
duration: 15min
difficulty: 🟢 Recipe
prerequisite: 14-hackathon
next: null
aha_moment: "Full lifecycle — rails new to production"
progress_file: ./progress.md
---

# Mentor Guide: 15-deploy

## Teaching Goal

The deploy is NOT a teaching moment. It's a celebration. Students follow 3 commands and their app is live. Don't explain Docker, Kamal internals, or infrastructure. Just make it work and let them feel the moment.

---

## Prerequisites (Facilitator Prep BEFORE Workshop)

- [ ] VMs provisioned with wildcard domain (*.oddlyhonest.dev)
- [ ] SSH keys distributed to teams
- [ ] Docker installed on VMs
- [ ] GitHub Container Registry access set up
- [ ] KAMAL_REGISTRY_PASSWORD set in .kamal/secrets
- [ ] DATABASE_URL configured on VM (PostgreSQL running)
- [ ] RAILS_MASTER_KEY available

If ANY of these aren't ready — skip this step. The hackathon IS the finale. Deploy is a bonus.

---

## Timing

| Section | Time | Notes |
|---------|------|-------|
| Config deploy.yml | 3 min | Team fills in their hostname |
| kamal setup | 5 min | First time takes longest — Docker install etc |
| kamal deploy | 5 min | Build + push + deploy |
| Celebrate | 2 min | Open browser, see it live |

---

## If It Fails

**Don't debug.** Say: "Sometimes deploys need a second try. The important thing is — you built a complete app in 2 days. That's what matters."

If there's time, try `kamal deploy` again. If it fails again, move to wrap-up. The deploy is NOT the point of the workshop.

---

## Wrap-Up (16:15–16:30)

After deploy (or if deploy is skipped), close the workshop:

1. **Recap what they built:** rails new → scaffold → auth → business rules → tests → tags → rich text → images → migrations → ERD → Turbo Frames → Turbo Streams → Stimulus → hackathon → deploy
2. **The ethos:** Business → Database → Everything Else Follows
3. **The skill:** "Give me any business problem, I'll sketch the ERD. That's what AI can't replace."
4. **Next steps:** Point to companion docs, the repo, and encourage them to run the workshop for their teams
5. **Feedback:** Ask what surprised them most

---

## Progress Logging

```markdown
## Branch 15-deploy
### Deploy
- VM accessible: [✅/❌]
- kamal setup succeeded: [✅/❌]
- kamal deploy succeeded: [✅/❌]
- App live at URL: [URL or skipped]

### Workshop Wrap-Up
- Completed Day 1: [✅/❌]
- Completed Day 2: [✅/❌]
- Hackathon feature: [which one]
- Hackathon demo: [✅/❌]
- Most surprising learning: [student response]
```
