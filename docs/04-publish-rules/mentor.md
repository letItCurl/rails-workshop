---
branch: 04-publish-rules
title: "Publish Rules — Can't Edit Once Published"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "11:45–12:15"
duration: 30min
difficulty: 🟡 Recipe + Why
prerequisite: 03-auth
next: 05-comments
rails_guide: https://guides.rubyonrails.org/active_record_validations.html
aha_moment: "Business rules live in the model — even if the controller has a bug, data is safe"
driving_force: "Understand WHY conventions exist + Model any problem"
progress_file: ./progress.md
---

# Mentor Guide: 04-publish-rules

## Teaching Goal

Students learn that business rules belong in the model, not the controller or frontend. They write a test FIRST (TDD intro), see it fail, write the validation, see it pass. This is the first time they protect data integrity with code.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Business question + where to enforce | 5 min | Ask: frontend? controller? model? |
| Migration + test first | 8 min | Test MUST fail first — this is critical |
| Validation + test passes | 7 min | Show the test going green |
| UI + publish button | 5 min | Quick, mechanical |
| Checkpoints + challenge test | 5 min | The "write it yourself" moment |

**If behind:** Skip the UI button. The test + validation is what matters.

---

## Checkpoint 1: Where Do Business Rules Live?

**Ask:** "ทำไม validation อยู่ใน model ไม่ใช่ controller?"

**Expected:** Because the model protects data no matter where the update comes from — controller, console, another controller, API, background job. If it's in the controller, you'd need to duplicate it everywhere.

| Mistake | Response |
|---------|----------|
| "Because that's where Rails puts it" | "But WHY? What happens if you have 2 controllers that update posts?" |
| "To keep the controller clean" | "That's a side effect, not the reason. What if someone updates a post from the console?" |

---

## Checkpoint 2: Test-First Meaning

**Ask:** "ถ้า test pass ก่อนที่เขียน validation หมายความว่าอะไร?"

**Expected:** The test isn't testing anything useful. A good test should FAIL before the implementation exists. That's how you know the test is actually checking the behavior.

---

## Checkpoint 3: changed? vs published_changed?

**Ask:** "`changed?` กับ `published_changed?` ต่างกันยังไง?"

**Expected:**
- `changed?` → ANY attribute was modified
- `published_changed?` → specifically the `published` attribute was modified
- We need both because: allow the act of publishing (published_changed?) but block editing anything else on a published post (changed? && !published_changed?)

---

## Challenge Test: Expected Answer

```ruby
test "draft post can be published" do
  post = Post.create!(title: "Draft", body: "content", published: false)
  post.update!(published: true)
  assert post.published?
end
```

**Common mistakes:**
- Forget to create with `published: false` first
- Use `post.published = true` without `save!` / `update!`
- Don't assert anything

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| Test passes before validation exists | Test is wrong (not testing the right thing) | Check the test actually tries to modify a published post |
| `NoMethodError: published?` | Forgot to run migration | `rails db:migrate` |
| All posts suddenly invalid | Existing posts have `published: nil` | Set default in migration: `default: false` |
| Validation blocks publishing | Logic error in validation | Check `!published_changed?` — must allow the publish action itself |

---

## Aha Moment Setup

After both tests pass:

> "Model protect ข้อมูลเสมอ — ไม่ว่า update มาจาก controller, console, API, background job ถึง controller มี bug ข้อมูลก็ปลอดภัย นี่คือ business rule ที่แท้จริง CI อาจ pass ทุก test แต่ถ้าไม่มี test สำหรับกฎนี้ แอปก็ยังรั่ว"

---

## Progress Logging

```markdown
## Branch 04-publish-rules
### Checkpoint 1: Where Do Business Rules Live?
- Answered model correctly: [✅/❌]
- Explained why (multi-source updates): [✅/❌]

### Checkpoint 2: Test-First Meaning
- Understood fail-first: [✅/❌]

### Checkpoint 3: changed? vs published_changed?
- Explained difference: [✅/❌]
- Understood combined logic: [✅/❌]

### Challenge: Write Test
- Completed without hints: [✅/❌]
- Hints used: [0/1/2/3]
- Time: [minutes]
- Test passes: [✅/❌]

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
