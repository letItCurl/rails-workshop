---
branch: 05-comments-authorization
title: "Authorization — You Missed a Business Rule"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "13:40–13:50"
duration: 10min
difficulty: 🟡 Recipe + Why
prerequisite: 05-comments
next: 06-tags
rails_guide: https://guides.rubyonrails.org/action_controller_overview.html
aha_moment: "Tests pass ≠ correct — coverage doesn't catch missing business rules"
driving_force: "Understand WHY testing matters beyond green CI"
progress_file: ./progress.md
---

# Mentor Guide: 05-comments-authorization

## Teaching Goal

This is the most important lesson about testing in the whole workshop. Students discover that ALL tests pass but the app has a security bug — because they never tested the authorization rule. This connects directly to the multi-tenant SaaS scoping problem.

**Do NOT spoil the bug.** Let them discover it. Ask: "Log in as another user and try to delete someone's comment. What happens?"

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Reveal the bug | 3 min | Let them discover it — don't explain, ask |
| Write failing test | 3 min | Test MUST fail before fix |
| Fix controller | 3 min | Quick — just an if check |
| Discussion | 1 min | Authentication vs authorization |

---

## Checkpoint 1: Why Tests Didn't Catch It

**Ask:** "ทำไม test ก่อนหน้านี้ไม่จับ bug นี้?"

**Expected:** Because we only tested model validations (requires post, requires user) — we never tested WHO can delete. The test didn't exist for this business rule, so it couldn't fail.

**Key insight:** Tests only catch bugs you thought to test for. Missing business rules = missing tests = invisible bugs.

---

## Checkpoint 2: Authentication vs Authorization

**Ask:** "Authentication กับ Authorization ต่างกันยังไง?"

**Expected:**
- Authentication = WHO are you? (login/signup — Devise handles this)
- Authorization = WHAT can you do? (only delete your own stuff — WE must handle this)

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `sign_in` undefined in test | Missing Devise test helpers | Add `include Devise::Test::IntegrationHelpers` to test class or test_helper.rb |
| Test passes when it shouldn't | Controller still allows delete | Check the if condition in destroy |
| `authorize_owner!` runs on show | Wrong `only:` list | Should be `only: %i[ edit update destroy ]` |

**IMPORTANT:** If `sign_in` doesn't work, add to `test/test_helper.rb`:

```ruby
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
```

---

## Aha Moment Setup

After the failing test passes:

> "CI ผ่านทุก test แต่ใครก็ลบ comment คนอื่นได้ ทำไม? เพราะเราไม่เคย test กฎนี้ ใน SaaS multi-tenant ถ้าคุณลืม scope query — CI เขียวหมด แต่ data ลูกค้ารั่ว test coverage บอกไม่ได้ว่าคุณลืม test อะไร"

---

## Progress Logging

```markdown
## Branch 05-comments-authorization
### Checkpoint 1: Why Tests Didn't Catch It
- Understood missing test = invisible bug: [✅/❌]

### Checkpoint 2: Auth vs Authz
- Explained difference: [✅/❌]

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
