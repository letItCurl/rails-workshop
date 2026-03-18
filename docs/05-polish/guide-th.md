---
branch: 05-polish
title: "Polish — Validations + UI ที่ซื่อสัตย์"
lang: th
pair: guide-en.md
day: 1
time: "13:45–13:50"
duration: 5min
difficulty: 🟢 Recipe
prerequisite: 05-comments-authorization
next: 06-tags
rails_guide: https://guides.rubyonrails.org/active_record_validations.html
aha_moment: "Defense in depth — block ที่ model, block ที่ controller, ซ่อนที่ view"
business_rule: "โพสต์ต้องมี title กับ body, comment ต้องมี body, UI ไม่โชว์ปุ่มที่กดไม่ได้"
---

# 🧹 ทำให้แอปซื่อสัตย์

ก่อนไปต่อ มีสองอย่างที่ต้องแก้:

**ปัญหาที่ 1:** ลองสร้างโพสต์เปล่าๆ — ไม่มี title ไม่มี body กด save ดู

ได้มั้ย? **ได้** และนั่นไม่ควรเป็นแบบนั้น

**ปัญหาที่ 2:** Login เป็น User A แล้วดูโพสต์ของ User B — เห็นปุ่ม Edit กับ Delete มั้ย?

เห็น แต่กดแล้วก็ถูก redirect กลับมา — controller block อยู่ แต่ UI โกหก user

---

## เพิ่ม Validations

เปิด `app/models/post.rb` เพิ่ม:

```ruby
validates :title, presence: true
validates :body, presence: true
```

เปิด `app/models/comment.rb` เพิ่ม:

```ruby
validates :body, presence: true
```

ทดสอบใน console:

```ruby
rails console
Post.create(title: "", body: "")  # ต้อง fail
Comment.create(body: "")           # ต้อง fail
```

---

## ซ่อนปุ่มสำหรับ non-owners

เปิด `app/views/posts/show.html.erb` — ครอบปุ่ม Edit, Publish, Delete ด้วย:

```erb
<% if current_user == @post.user %>
  <%# ... edit, publish, delete buttons ... %>
<% end %>
```

ทำเหมือนกันกับ delete ใน comment — โชว์เฉพาะ owner หรือ post author:

```erb
<% if current_user == comment.user || current_user == @post.user %>
  <%# ... delete link ... %>
<% end %>
```

**หลักการ:** Defense in depth — ทั้ง 3 layer protect:
1. **Model** — validations block bad data
2. **Controller** — authorization block unauthorized actions
3. **View** — UI ไม่โชว์สิ่งที่ทำไม่ได้

---

## ✅ ก่อนไปต่อ

- [ ] โพสต์เปล่าสร้างไม่ได้
- [ ] Comment เปล่าสร้างไม่ได้
- [ ] Non-owner ไม่เห็นปุ่ม Edit/Delete
- [ ] Owner เห็นปุ่มปกติ

---

## ➡️ ต่อไป: Branch `06-tags`

ของจริงมาแล้ว — has_many :through, the one kick
