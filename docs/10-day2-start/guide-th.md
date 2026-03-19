---
branch: 10-day2-start
title: "Day 2 — ยินดีต้อนรับกลับ"
lang: th
pair: guide-en.md
day: 2
time: "9:30–10:00"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 09-erd-exercise
next: 11-turbo-frames
---

# ☀️ Day 2 — ยินดีต้อนรับกลับ

เมื่อวานคุณทำอะไรมาบ้าง? ลองนึกดู:

- สร้างแอปจาก `rails new` — 3 คำสั่งได้ CRUD ครบ
- อ่าน routes + schema แล้วเข้าใจแอปทั้งหมดจาก 2 ไฟล์
- เพิ่ม auth ด้วย Devise — 3 คำสั่งได้ signup/login/logout
- เขียน business rule ใน model — โพสต์ publish แล้วแก้ไม่ได้
- เขียน test ก่อน code — fail ก่อนแล้ว pass
- ค้นพบว่า test pass ≠ ไม่มี bug (authorization)
- สร้าง comments ด้วย scaffold แล้ว**ลบ** edit ออก — business decision
- Master has_many :through กับ join table — the one kick
- เห็น SQL จริงที่ ActiveRecord สร้าง — ไม่มี magic
- เพิ่ม rich text + images — zero custom code
- รอดจาก migration conflict
- Model 5 ธุรกิจเป็น ERD — ทักษะที่ย้ายได้

**ทั้งหมดนี้ในวันเดียว**

---

## วันนี้คุณจะทำอะไร?

วันนี้คือ **Turbo Day** — คุณจะค้นพบว่า Rails จัดการ frontend ได้ด้วย **ไม่ต้องเขียน JavaScript เลย**

เมื่อวานคุณสร้าง backend ที่แข็งแกร่ง วันนี้คุณจะทำให้มัน interactive:

| เวลา | สิ่งที่จะทำ | aha moment |
|------|-----------|-----------|
| 9:30–10:00 | อ่าน codebase ใหม่ | "ฉันอ่าน Rails app ได้จาก routes + schema" |
| 10:00–11:00 | Turbo Frames | "Inline editing ไม่มี JS เลย" |
| 11:15–12:15 | Turbo Streams | "Real-time updates — 2 lines of code" |
| 13:15–13:45 | Stimulus | "JS ที่จำเป็นจริงๆ มีแค่นี้" |
| 14:00–15:45 | Hackathon | "ฉันทำ Business → DB → Code ได้เองแล้ว" |
| 16:00–16:15 | Deploy (stretch) | "แอปฉันอยู่บน internet" |

---

## แอปที่คุณเห็น

แอปที่คุณกำลังเปิดอยู่คือ OddlyHonest — เหมือนที่คุณสร้างเมื่อวาน แต่ UI ถูก polish ให้ดูเหมือนแอปจริง:

- **Layout:** Centered column เหมือน Medium
- **Typography:** Georgia serif สำหรับ content
- **Trix editor:** Styled toolbar, sticky, wrapping
- **Notifications:** Auto-dismiss หลัง 3 วินาที
- **Confirm dialog:** Custom modal แทน browser default
- **Tags:** Pill badges
- **Cover images:** Full-width hero

**ทุกอย่างที่เพิ่มมาคือ CSS + 2 Stimulus controllers** ไม่มี feature ใหม่ แค่ polish

---

## เริ่มต้น

```bash
git checkout 10-day2-start
bundle install
rails db:setup
bin/dev
```

เปิด http://localhost:3000 — login ด้วย `demo@oddlyhonest.com` / `password`

---

## 🔍 อ่าน Codebase

ก่อนเขียนโค้ด — **อ่านก่อน**

1. **เปิด `config/routes.rb`** — มี resources อะไรบ้าง?
2. **เปิด `db/schema.rb`** — มีกี่ tables? relationships เป็นยังไง?
3. **เปิด models** (`app/models/`) — อ่าน associations กับ validations
4. **อย่าเพิ่งอ่าน controllers หรือ views**

**ถามกลุ่ม:** อธิบายแอปนี้ให้คนข้างๆ ฟัง โดยดูแค่ routes + schema

---

## สำหรับคนที่ไม่ได้มา Day 1

ไม่เป็นไร! แอปนี้ ready แล้ว คุณไม่ต้องสร้างเอง

สิ่งที่ควรรู้:
- **Post** มี title, rich text body, cover image, published flag, tags
- **Comment** belongs_to Post + User, แก้ไขไม่ได้
- **Tag** เชื่อมกับ Post ผ่าน PostTag (has_many :through)
- **User** ใช้ Devise (signup/login/logout)
- เฉพาะเจ้าของเท่านั้นที่ edit/delete ได้

ถ้าอยากเข้าใจ has_many :through ลึกขึ้น อ่าน `docs/06-tags-deep-dive/guide-th.md`

---

## ✅ ก่อนไปต่อ

- [ ] แอป run ได้ที่ localhost:3000
- [ ] login ด้วย demo account ได้
- [ ] อ่าน routes.rb แล้วบอกได้ว่ามี resources อะไรบ้าง
- [ ] อ่าน schema.rb แล้วบอกได้ว่ามีกี่ tables
- [ ] อธิบาย relationships ระหว่าง models ได้

---

## ➡️ ต่อไป: Branch `11-turbo-frames`

คุณอยากแก้โพสต์ inline ไม่ต้อง reload หน้า — ทำยังไง? ไม่ต้องเขียน JavaScript เลย
