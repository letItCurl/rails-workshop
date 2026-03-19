---
branch: 12-turbo-challenge
title: "Turbo Challenge — Real-time Index"
lang: th
pair: guide-en.md
day: 2
time: "12:00–12:15"
duration: 15min
difficulty: 🔴 Challenge
prerequisite: 12-turbo-deep-dive
next: 13-stimulus
aha_moment: "ฉันใช้ Turbo Streams ได้เอง"
business_rule: "โพสต์ใหม่โผล่ real-time บน index ทุกคน"
---

# Turbo Challenge — Real-time Index

## โจทย์

ตอนนี้ระบบ blog ของเราทำงานปกติ — สร้างโพสต์ได้ ดูรายการได้ แต่ถ้ามีคนสร้างโพสต์ใหม่ คนอื่นที่เปิดหน้า index อยู่จะไม่เห็น ต้อง refresh ก่อน

**เป้าหมาย:** ทำให้หน้า index เป็น real-time — เมื่อใครก็ตามสร้างโพสต์ใหม่ โพสต์นั้นจะโผล่ขึ้นมาบนหน้า index ของทุกคนทันที โดยไม่ต้อง refresh

## สิ่งที่ต้องทำ

คุณต้องหาวิธีเองว่าต้องแก้ไขอะไรบ้าง แต่บอกใบ้ได้ว่ามี 3 จุดที่ต้องแตะ:

1. **View** — หน้า index ต้อง subscribe รับ stream
2. **Model** — Post model ต้อง broadcast เมื่อมีการสร้างใหม่
3. **Partial** — partial ต้องรองรับการ broadcast (ต้องมี `dom_id`)

## ทดสอบ

1. เปิด 2 tabs บนหน้า posts index
2. ที่ tab A กดสร้างโพสต์ใหม่
3. ดูที่ tab B — โพสต์ใหม่ต้องโผล่ขึ้นมาเองโดยไม่ต้อง refresh

---

## Hints

เปิดทีละอันเมื่อติดจริงๆ

<details>
<summary>Hint 1 — เริ่มจากไหน?</summary>

ดูที่ view ก่อน — หน้า index ต้องมีตัว subscribe เข้ากับ channel ชื่อ `"posts"` ลองหา helper ของ Turbo ที่ทำหน้าที่นี้

</details>

<details>
<summary>Hint 2 — Subscribe ยังไง?</summary>

เพิ่ม `turbo_stream_from "posts"` ในไฟล์ `index.html.erb` — บรรทัดนี้จะสร้าง WebSocket subscription เข้ากับ channel ชื่อ `"posts"`

</details>

<details>
<summary>Hint 3 — Model ต้องทำอะไร?</summary>

ใน Post model ต้องบอกให้ broadcast ไปที่ channel `"posts"` ทุกครั้งที่มีการสร้าง/แก้ไข/ลบ ลองดู `broadcasts_to` — แต่ระวัง ถ้าใส่ symbol เฉยๆ มันจะ broadcast ไป channel ของแต่ละ record แทน

</details>

<details>
<summary>Hint 4 — Lambda vs Symbol</summary>

ใช้ `broadcasts_to ->(post) { "posts" }` ไม่ใช่ `broadcasts_to :posts`

- **Lambda** `->(_post) { "posts" }` — ส่งไปที่ channel ชื่อ `"posts"` เสมอ (fixed channel) ทุกโพสต์ broadcast ไปที่เดียวกัน เหมาะสำหรับ index page
- **Symbol** `broadcasts_to :author` — ส่งไปที่ channel ของ association เช่น `author_1`, `author_2` แต่ละ record ไปคนละ channel ไม่เหมาะกับกรณีนี้

</details>

---

## Checkpoints

### Checkpoint 1 — ใช้งานได้ไหม?

เปิด 2 tabs บน index → สร้างโพสต์ใน tab A → โพสต์ใหม่โผล่ใน tab B ทันทีหรือไม่?

ถ้าใช่ ผ่าน!

### Checkpoint 2 — อธิบายได้ไหม?

`broadcasts_to ->(post) { "posts" }` กับ `broadcasts_to :something` ต่างกันยังไง?

**คำตอบ:** Lambda จะ return ชื่อ channel เป็น string คงที่ — ทุก post broadcast ไปที่ channel เดียวกัน เหมาะกับกรณีที่อยากให้ทุกคนที่ดู index เห็นการเปลี่ยนแปลง ส่วน symbol จะเรียก association แล้วสร้าง channel ตาม record นั้นๆ เช่น `broadcasts_to :author` จะ broadcast ไปที่ channel ของ author แต่ละคน เหมาะกับกรณีที่อยากให้เฉพาะคนที่ดูหน้าของ author คนนั้นเห็น

---

## ต่อไป: Branch `13-stimulus`

Turbo จัดการ real-time ให้หมด แล้ว JavaScript ล่ะ? มียังที่ต้องเขียนจริงๆ มั้ย?
