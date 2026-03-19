---
branch: 12-turbo-deep-dive
title: "Deep Dive — Turbo ทำงานยังไงจริงๆ"
lang: th
pair: guide-en.md
day: 2
time: "12:00–12:15"
duration: 15min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 12-turbo-streams
next: 13-stimulus
rails_guide: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
aha_moment: "HTML over the wire — ไม่มี JSON, ไม่มี JS, แค่ HTML fragments"
---

# Deep Dive — Turbo ทำงานยังไงจริงๆ

คุณสร้าง inline editing กับ real-time comments ได้แล้ว มันทำงาน แต่คุณรู้มั้ยว่า ข้างในเกิดอะไรขึ้น?

Step นี้ไม่มี code ใหม่ เราจะเปิดฝาดูว่า Turbo ทำอะไรอยู่เบื้องหลัง

---

## The Golden Rule

ทุก non-GET request (POST, PATCH, DELETE) ผ่าน Turbo อัตโนมัติ

- Forms ถูก intercept โดย Turbo — ไม่มี full page reload
- Clicks ใน `<turbo-frame>` ถูก intercept — Turbo fetch เฉพาะ frame นั้น
- คุณไม่ต้องทำอะไร — Turbo ทำให้

คุณเขียน HTML ปกติ Rails render HTML ปกติ แต่ Turbo เป็นคนจัดการว่าจะเอา HTML ไปใส่ตรงไหน

---

## Exercise: DevTools Network Tab

ลองทำตามนี้:

1. เปิด DevTools (`Cmd+Opt+I` บน Mac) แล้วไปที่ **Network** tab
2. ไปที่ draft post แล้วกด **"Edit inline"**
3. ดู request ที่เกิดขึ้น — Turbo fetch หน้า edit

ดู response ดีๆ — **มันเป็น HTML ทั้งหน้า!** มี `<html>`, `<head>`, `<body>` ครบ

แต่ Turbo ไม่ได้ใช้ทั้งหน้า มัน extract เฉพาะ `<turbo-frame id="post_123">` ที่ ID ตรงกับ frame ในหน้าปัจจุบัน

ที่เหลือ? **ทิ้งหมด** เอาแค่ส่วนที่ match

กระบวนการคือ:
1. User กด Edit ใน `<turbo-frame id="post_42">`
2. Turbo intercept click → fetch GET `/posts/42/edit`
3. Server render `edit.html.erb` ทั้งหน้า (เหมือนปกติ)
4. Turbo รับ HTML → หา `<turbo-frame id="post_42">` ใน response
5. เจอ! → เอา content มาแทนที่ frame เดิมใน DOM
6. ที่เหลือของ response ทิ้งหมด

---

## What if no matching ID?

ลองทดลอง: เปลี่ยน ID ใน `edit.html.erb` เป็นอย่างอื่น เช่น `post_wrong`

กด Edit อีกครั้ง → **content หายไป!**

เพราะ Turbo หา frame ที่ match ไม่เจอ → ใส่ empty content เข้าไปแทน

นี่คือ bug ที่พบบ่อยมาก — ถ้า ID ไม่ตรง content จะหายเงียบๆ ไม่มี error

> อย่าลืม revert กลับนะ!

---

## Turbo Streams format

Turbo Frames ต้อง match ID เสมอ แต่ **Turbo Streams** ต่างออกไป

เมื่อ server respond ด้วย `.turbo_stream` format แทน HTML ปกติ:

```html
<turbo-stream action="append" target="comments">
  <template>
    ...comment partial HTML...
  </template>
</turbo-stream>
```

Turbo อ่าน:
- **action** — จะทำอะไร: `append`, `prepend`, `replace`, `remove`, `update`
- **target** — DOM element ไหน (ใช้ id)

แล้วทำตาม ไม่ต้อง match frame — **บอกตรงๆ ว่าจะเปลี่ยนอะไร**

Streams = คำสั่งจาก server บอก browser ว่า "เอา HTML นี้ไป append ที่ element ที่มี id นี้"

---

## broadcasts_to under the hood

`broadcasts_to :post` ที่เราใส่ใน Comment model — มันทำอะไร?

**สิ่งที่เกิดขึ้นจริง:**

1. `broadcasts_to :post` registers **after_create** + **after_destroy** callbacks ใน ActiveRecord
2. เมื่อ comment ถูกสร้าง:
   - Rails renders `_comment.html.erb` partial
   - Wrap ใน `<turbo-stream action="append" target="comments">`
   - Push ผ่าน **Action Cable WebSocket** ไปหา browser ทุกตัวที่ subscribe อยู่
3. เมื่อ comment ถูกลบ:
   - Push `<turbo-stream action="remove" target="comment_123">`
   - ไม่ต้อง render อะไร — แค่บอก browser ว่าเอาออก

**`turbo_stream_from @post`** ใน view = สร้าง WebSocket subscription ไปที่ channel ที่ตั้งชื่อตาม post

ทุก browser ที่เปิดหน้า post เดียวกัน subscribe channel เดียวกัน เมื่อมี comment ใหม่ ทุกคนได้รับ HTML fragment เดียวกัน

---

## Exercise: DevTools WS tab

ลองทำตามนี้:

1. เปิด DevTools → **Network** tab → filter เลือก **WS** (WebSocket)
2. Refresh หน้า post — เห็น WebSocket connection ไปที่ `/cable`
3. กดเข้าไปดู — เห็น **Messages** tab
4. เปิดอีก browser tab (หรือ incognito) ไปที่ post เดียวกัน
5. Post comment จาก tab ที่สอง
6. กลับมาดู tab แรก — ดู message ที่ถูก push เข้ามา

**มันเป็น HTML!** ไม่ใช่ JSON ไม่ใช่ data — เป็น HTML fragment พร้อมใช้

---

## The Full Picture

ตอนนี้เราเห็นภาพรวมแล้ว:

**Turbo Drive** — intercepts ทุก link click + form submit → fetch HTML → replace `<body>` ทั้งก้อน

**Turbo Frames** — intercepts ภายใน box → fetch HTML → replace เฉพาะ `<turbo-frame>` ที่ ID match

**Turbo Streams** — server push/respond ด้วย HTML fragments → actions: append / prepend / replace / remove / update

**ทั้งหมด = HTML over the wire**

ไม่มี JSON API ไม่มี client-side rendering ไม่มี state management

Server render HTML → ส่งให้ browser → browser ใส่ DOM

นี่คือ philosophy ของ Hotwire: **server เป็นคน render ทุกอย่าง browser เป็นแค่คน display**

---

## Checkpoints

### Checkpoint 1
ทุก non-GET request ผ่านอะไร?

### Checkpoint 2
ถ้า turbo-frame ID ใน show page ไม่ตรงกับ ID ใน edit page จะเกิดอะไร?

### Checkpoint 3
`broadcasts_to` register callbacks อะไร? push อะไรผ่าน WebSocket?

### Checkpoint 4
ความแตกต่างระหว่าง Turbo Frames กับ Turbo Streams คืออะไร?
