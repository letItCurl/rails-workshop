---
branch: 05-comments
title: "Comments — Permanent Reactions"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 1
time: "13:15–13:50"
duration: 35min
difficulty: 🟡 Recipe + Why
prerequisite: 04-publish-rules
next: 06-tags
rails_guide: https://guides.rubyonrails.org/association_basics.html
aha_moment: "Scaffold gives everything, you choose what to remove — business decision not technical"
driving_force: "Understand WHY conventions exist"
progress_file: ./progress.md
---

# Mentor Guide: 05-comments

## Teaching Goal

Students understand `belongs_to` as a database concept (foreign key), not an abstract Rails thing. They experience the power of scaffold + the discipline of removing what you don't need. The "remove edit" moment is the aha — Rails gives you the full toolkit, business decisions determine what stays.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Business question + scaffold | 8 min | Ask about relationships BEFORE scaffolding |
| Wire models + dependent | 5 min | Quick |
| Remove edit/update | 7 min | THIS is the aha — make it deliberate |
| Login + show on post page | 10 min | Form on post show, redirect back |
| Checkpoints + challenge | 5 min | |

**If behind:** Skip the challenge test. Never skip the "remove edit" moment.

---

## Checkpoint 1: belongs_to in Database Terms

**Ask:** "`belongs_to :post` ใน Comment หมายความว่าอะไรใน database?"

**Expected:** There's a `post_id` column in the comments table. It's a foreign key pointing to the posts table. A comment cannot exist without a post.

| Mistake | Response |
|---------|----------|
| "It means they're related" | "HOW? What column makes this connection? Open schema.rb." |
| "It means post owns comment" | "Close — but what's in the DATABASE that enforces this? What if post_id is nil?" |

---

## Checkpoint 2: Why Remove Routes, Not Just Hide Buttons

**Ask:** "ทำไมลบ edit/update จาก routes แทนที่จะแค่ซ่อนปุ่ม?"

**Expected:** Because hiding the button is frontend-only — someone can still send a PATCH request directly (via curl, Postman, etc.). Removing the route means the server literally doesn't accept that request. Defense in depth.

---

## Checkpoint 3: dependent :destroy

**Ask:** "`dependent: :destroy` ทำอะไร? ถ้าไม่ใส่?"

**Expected:**
- With it: deleting a post also deletes all its comments
- Without it: comments become orphans — `post_id` points to a deleted post, causing errors

**Follow-up:** "What if we used `dependent: :nullify`?" → sets post_id to nil, comments remain but detached

---

## Challenge Test: Expected Answer

```ruby
test "comment requires a post" do
  user = User.create!(email: "test@test.com", password: "password")
  comment = Comment.new(body: "test", user: user, post: nil)
  assert_not comment.valid?
end
```

Note: This test works because `belongs_to` validates presence by default in Rails 5+.

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `NoMethodError: comments` on Post | Forgot `has_many :comments` in Post model | Add it |
| Comment form doesn't include post_id | Missing hidden field | `f.hidden_field :post_id, value: @post.id` |
| `Unpermitted parameter: :post_id` | Forgot to permit in comment_params | Add `:post_id` to permitted params |
| Comments show on wrong page | Redirect goes to comments#index | Redirect to `post_path(@comment.post)` |
| `undefined method 'edit_comment_path'` | edit route was removed but view still references it | Delete edit.html.erb |

---

## Aha Moment Setup

After they delete the edit action and route:

> "Scaffold ให้ CRUD ครบ 7 actions แต่ OddlyHonest บอกว่า comment แก้ไม่ได้ คุณก็แค่ลบออก Rails ให้ toolkit ทั้งหมด — business ตัดสินใจว่าจะเก็บอะไร นี่ไม่ใช่ technical decision นี่คือ business decision ที่แปลงเป็นโค้ด"

---

## Progress Logging

```markdown
## Branch 05-comments
### Checkpoint 1: belongs_to in DB
- Mentioned post_id column: [✅/❌]
- Mentioned foreign key: [✅/❌]

### Checkpoint 2: Why Remove Routes
- Understood defense in depth: [✅/❌]

### Checkpoint 3: dependent :destroy
- Correct answer: [✅/❌]
- Knew about :nullify: [✅/❌]

### Challenge: Write Test
- Completed without hints: [✅/❌]
- Hints used: [0/1/2/3]
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
