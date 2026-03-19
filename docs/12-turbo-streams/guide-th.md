---
branch: 12-turbo-streams
title: "Turbo Streams — Real-time ไม่ต้อง JS"
lang: th
pair: guide-en.md
day: 2
time: "11:15–12:00"
duration: 45min
difficulty: "\U0001F534 Challenge"
prerequisite: 11-turbo-frames
next: 12-turbo-deep-dive
rails_guide:
  - https://guides.rubyonrails.org/working_with_javascript_in_rails.html
  - https://guides.rubyonrails.org/action_cable_overview.html
aha_moment: "Real-time updates — 2 lines of code ไม่มี JavaScript"
business_rule: "Comment ใหม่โผล่ให้ทุกคนที่ดูโพสต์เดียวกัน instantly"
---

# Turbo Streams — Real-time ไม่ต้อง JS

## สถานการณ์

คุณกำลังอ่านโพสต์อยู่ คนอื่น comment เข้ามา — ต้อง refresh มั้ย?

ใน React ต้อง setup WebSocket connection, manage state subscription, re-render component... กี่ร้อยบรรทัด? ต้อง install อะไรอีกกี่ตัว?

ใน Rails 8 ใช้ **2 บรรทัด** ไม่ต้องเขียน JavaScript สักบรรทัดเดียว

---

## Turbo Streams คืออะไร?

Turbo Streams คือกลไกที่ server **push HTML fragments** ไปยัง browser ผ่าน WebSocket โดยตรง browser รับ HTML มาแล้ว insert, replace, หรือ remove DOM elements ให้อัตโนมัติ

ไม่ต้องเขียน JS ไม่ต้อง parse JSON ไม่ต้อง manage state — server ส่ง HTML สำเร็จรูปมาเลย

---

## Step 1: สร้าง Comment Partial

สร้างไฟล์ `app/views/comments/_comment.html.erb`:

```erb
<%= turbo_frame_tag comment do %>
  <div class="comment-card">
    <div class="comment-body">
      <%= simple_format(comment.body) %>
    </div>
    <div class="comment-meta">
      <span class="comment-date"><%= time_ago_in_words(comment.created_at) %> ago</span>
      <%= button_to "Delete", post_comment_path(comment.post, comment),
            method: :delete,
            class: "btn-delete-comment" %>
    </div>
  </div>
<% end %>
```

ทำไมต้องมี partial? เพราะ `broadcasts_to` จะใช้ partial นี้ในการ render HTML ที่จะ broadcast ไปให้ทุกคน ชื่อไฟล์ต้องตรงกับ model — `_comment.html.erb` สำหรับ `Comment`

---

## Step 2: Update Show View

เปิด `app/views/posts/show.html.erb` แล้วเพิ่ม 2 สิ่ง:

**2a.** เพิ่ม `turbo_stream_from` **ก่อน** comments div:

```erb
<%= turbo_stream_from @post %>
```

บรรทัดนี้บอก browser ว่า "subscribe to WebSocket channel ของ post นี้"

**2b.** เปลี่ยน loop comments ให้ใช้ partial:

```erb
<div id="comments">
  <%= render @post.comments %>
</div>
```

`render @post.comments` จะ render `_comment.html.erb` สำหรับแต่ละ comment อัตโนมัติ

---

## Step 3: broadcasts_to ใน Comment Model

เปิด `app/models/comment.rb` แล้วเพิ่ม **1 บรรทัด**:

```ruby
class Comment < ApplicationRecord
  belongs_to :post

  broadcasts_to :post
end
```

แค่นี้เอง `broadcasts_to :post` บอก Rails ว่า "เวลา comment ถูกสร้างหรือลบ ให้ broadcast HTML ไปให้ทุกคนที่กำลังดู post เดียวกัน"

---

## Step 4: ทดสอบ!

1. เปิด 2 browser tabs บน post เดียวกัน
2. พิมพ์ comment ใน tab A แล้วกด submit
3. สังเกต tab B — comment ใหม่โผล่ขึ้นมา **ทันที** โดยไม่ต้อง refresh!
4. ลบ comment ใน tab A — หายไปจาก tab B เหมือนกัน

**มันเกิดขึ้นจริงๆ — real-time, zero JavaScript**

---

## เบื้องหลัง: broadcasts_to ทำงานยังไง?

1. `turbo_stream_from @post` สร้าง WebSocket subscription ไปยัง Action Cable channel เฉพาะสำหรับ post นั้น
2. เมื่อ comment ถูกสร้าง `broadcasts_to :post` จะ:
   - Render `_comment.html.erb` partial
   - สร้าง Turbo Stream `<turbo-stream action="append">` message
   - Broadcast HTML นั้นผ่าน WebSocket ไปยังทุก subscriber
3. Browser ที่ subscribe อยู่รับ HTML แล้ว append เข้าไปใน DOM อัตโนมัติ
4. เมื่อ comment ถูกลบ จะ broadcast `<turbo-stream action="remove">` แทน

ทั้งหมดนี้ Rails จัดการให้หมด

---

## Rails 8 Note: Solid Cable

Rails 8 ใช้ **Solid Cable** เป็น default adapter สำหรับ Action Cable — ไม่ต้อง install Redis! ใช้ database เป็น pub/sub backend แทน config อยู่ใน `config/cable.yml` พร้อมใช้งานเลย

---

## Checkpoints

### Checkpoint 1 (Green)

`broadcasts_to :post` ทำอะไร? แล้วต้องเพิ่มอะไร 1 บรรทัดใน view?

> `broadcasts_to :post` ทำให้ Rails broadcast HTML ไปให้ทุกคนที่ดู post เดียวกันเมื่อ comment ถูกสร้างหรือลบ
> ใน view เพิ่ม `turbo_stream_from @post` เพื่อ subscribe

### Checkpoint 2 (Yellow)

เปิด 2 tabs แล้ว comment ใน tab หนึ่ง — โผล่อีก tab มั้ย? เทคโนโลยีอะไรที่ทำให้มันเป็นไปได้?

> ใช่ โผล่ทันที เทคโนโลยีคือ WebSocket ผ่าน Action Cable (Solid Cable ใน Rails 8)

### Checkpoint 3 (Red)

ใน React ต้อง setup อะไรบ้างถึงจะได้ real-time updates แบบนี้?

> WebSocket connection management, state subscription/unsubscription, JSON parsing, component re-rendering, cleanup on unmount, error handling/reconnection... อย่างน้อย 4-5 ไฟล์ กับ library อีก 2-3 ตัว

---

## If Stuck

ปัญหาที่เจอบ่อย:

- **Comment ไม่ broadcast**: เช็คว่า Action Cable mount อยู่ใน `config/routes.rb` (`mount ActionCable.server => '/cable'`)
- **Partial not found error**: ชื่อไฟล์ต้องเป็น `_comment.html.erb` ตรงกับ model `Comment` และอยู่ใน `app/views/comments/`
- **turbo_stream_from ไม่ subscribe**: ต้องวาง `turbo_stream_from @post` **ก่อน** comments div ไม่ใช่หลัง
- **Comment โผล่ซ้ำ 2 ครั้ง**: เป็นเพราะทั้ง broadcast และ turbo stream response จาก controller ทำงานพร้อมกัน — ต้อง handle ใน controller ให้ถูก
- **ลบแล้วไม่หายจาก tab อื่น**: เช็ค `dependent: :destroy` ใน Post model หรือว่ามี `after_destroy` callback ถูกต้อง

---

## Self-Check

ถ้าทำถึงตรงนี้ได้ คุณมี real-time updates ทำงานแล้ว ด้วยโค้ดแค่ 2 บรรทัด:

1. `broadcasts_to :post` ใน model
2. `turbo_stream_from @post` ใน view

**แต่มันทำงานยังไงจริงๆ?** Action Cable channel ถูกสร้างยังไง? HTML ถูก render ที่ไหน? WebSocket message หน้าตาเป็นยังไง?

หลัง break เราจะแกะดูทุกชั้น ใน **Turbo Streams Deep Dive**
