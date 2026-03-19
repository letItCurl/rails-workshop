---
branch: 13-stimulus
title: "Stimulus — JS ที่จำเป็นจริงๆ"
lang: th
pair: guide-en.md
day: 2
time: "13:15–13:45"
duration: 30min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 12-turbo-challenge
next: 14-hackathon
rails_guide: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
aha_moment: "JS ที่ต้องเขียนจริงๆ มีแค่นี้ — small, scoped, HTML-driven"
business_rule: "ไม่มี business rule ใหม่ — เพิ่ม interactive behaviors"
---

# Stimulus — JS ที่จำเป็นจริงๆ

## Turbo จัดการให้หมดแล้ว… แล้ว JavaScript ล่ะ?

Turbo จัดการ navigation กับ real-time ให้หมด แล้ว JavaScript ล่ะ? มีเวลาไหนที่ต้องเขียนจริงๆ?

คำตอบ: น้อยมาก — Stimulus ทำให้คุณเขียนแค่ที่จำเป็น

ลองนึกดูนะ ตั้งแต่เช้าเราทำ inline editing ด้วย Turbo Frames, real-time ด้วย Turbo Streams — ไม่ได้เขียน JavaScript เลยสักบรรทัด แต่มี behavior เล็กๆ ที่ Turbo ทำไม่ได้ เช่น นับตัวอักษร, toggle element, auto-dismiss notification — พวกนี้แหละที่ Stimulus เข้ามาช่วย

---

## Stimulus คืออะไร?

Stimulus เป็น framework สำหรับ **small JavaScript behaviors** ย้ำ — small

- ไม่ใช่ SPA framework
- ไม่ replace React
- มันเพิ่ม interactivity เล็กๆ ให้ HTML ที่ server render มา

มี 3 concepts หลักที่ต้องรู้:

| Concept | คืออะไร | ตัวอย่าง |
|---------|---------|----------|
| **Controller** | JS class ที่ผูกกับ DOM element | `character_counter_controller.js` |
| **Target** | reference ไปหา DOM element ภายใน controller | `data-character-counter-target="input"` |
| **Action** | event ที่ trigger method ใน controller | `data-action="input->character-counter#countCharacters"` |

แค่ 3 อย่างนี้เอง Controller, Target, Action — จำง่ายๆ

---

## Build 1 — Character Counter

เราจะสร้าง controller ที่นับตัวอักษรใน comment form

### สร้าง controller

```bash
rails g stimulus character_counter
```

### เปิดไฟล์ที่ generate มา

เปิด `app/javascript/controllers/character_counter_controller.js` แล้วแก้เป็น:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.updateCount()
  }

  countCharacters() {
    this.updateCount()
  }

  updateCount() {
    const length = this.inputTarget.value.length
    this.countTarget.textContent = `${length} characters`
  }
}
```

### Wire เข้า comment form

ใน view ที่มี comment textarea ให้เพิ่ม data attributes:

```erb
<div data-controller="character-counter">
  <%= form.text_area :body,
    data: {
      character_counter_target: "input",
      action: "input->character-counter#countCharacters"
    } %>
  <span data-character-counter-target="count">0 characters</span>
</div>
```

### ทดสอบ

พิมพ์ใน comment box — จะเห็นตัวเลข character count อัพเดตแบบ live เลย

สังเกตนะ — ไม่มี `querySelector`, ไม่มี `addEventListener` ไม่ต้องจัดการ lifecycle เอง Stimulus จัดการให้หมด

---

## Build 2 — Toggle Comments

สร้าง controller ที่ซ่อน/แสดง comments section

### สร้าง controller

```bash
rails g stimulus toggle
```

### เขียน controller

เปิด `app/javascript/controllers/toggle_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

### Wire ใน show page

```erb
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">
    Hide/Show Comments
  </button>

  <div data-toggle-target="content">
    <%# comments section here %>
  </div>
</div>
```

### ทดสอบ

กดปุ่ม → comments หายไป กดอีกที → กลับมา

ง่ายมาก controller แค่ 5 บรรทัด ทำ toggle ได้เลย

---

## Checkpoint 1 (Green)

**3 concepts หลักของ Stimulus คืออะไร?**

หยุดคิดก่อนอ่านต่อ

> Controller, Target, Action

---

## Checkpoint 2 (Yellow)

**`data-action="input->character-counter#countCharacters"` ทำงานยังไง? แยกแต่ละส่วนออกมา**

หยุดคิดก่อนอ่านต่อ

> - `input` — event ที่ listen (เมื่อ user พิมพ์)
> - `character-counter` — ชื่อ controller (kebab-case)
> - `countCharacters` — method ที่จะ call

รูปแบบคือ: **event -> controller#method**

---

## THE REVEAL — Stimulus อยู่ในแอพเราตั้งแต่แรกแล้ว!

ตอนนี้เปิดไฟล์พวกนี้ดู:

### `app/javascript/controllers/notification_controller.js`

Flash message ที่หายไปเองหลัง 3 วินาที? นั่น Stimulus!

### `app/javascript/controllers/confirm_controller.js`

Custom delete confirmation modal? นั่นก็ Stimulus!

### `app/javascript/application.js`

Turbo confirm override ที่ใช้ Stimulus!

**คุณใช้ Stimulus มาตั้งแต่ Day 2 เริ่ม โดยไม่รู้ตัว**

ลองอ่าน notification_controller.js ทีละบรรทัด — จะเห็นว่ามันเป็น pattern เดียวกันกับ character counter และ toggle ที่เราเพิ่งสร้าง: Controller, Target, Action

---

## Checkpoint 3 (Red)

**ดู `notification_controller.js` — มันทำอะไร? `connect()` คืออะไร? `setTimeout` ทำอะไร?**

หยุดอ่าน code จริงก่อนอ่านต่อ

> - `connect()` ถูกเรียกอัตโนมัติเมื่อ controller ผูกกับ DOM element (เหมือน mounted ใน React)
> - `setTimeout` ตั้งเวลาให้ flash message หายไปหลัง 3 วินาที
> - มันใช้ pattern เดียวกับ controller ที่เราเพิ่งเขียน!

---

## ภาพรวม Hotwire ครบ

ตอนนี้เราเห็นภาพรวมทั้งหมดแล้ว:

| Layer | ทำอะไร | เทียบกับ React |
|-------|--------|----------------|
| **Turbo Drive** | Page navigation ไม่ต้อง reload | React Router |
| **Turbo Frames** | Update บางส่วนของ page | Component re-render |
| **Turbo Streams** | Real-time push updates | WebSocket + state management |
| **Stimulus** | Small JS behaviors | Event handlers + useEffect |

4 อย่างนี้รวมกัน replace ได้ 95% ของสิ่งที่ React ทำ — ด้วย code ที่น้อยกว่ามาก

---

## Self-check

ก่อนไปต่อ ลองตอบคำถามเหล่านี้:

- [ ] สร้าง Stimulus controller ได้ด้วย generator
- [ ] รู้ว่า Controller, Target, Action คืออะไร
- [ ] อ่าน data-action attribute แล้วแยกส่วนได้
- [ ] อ่าน existing controller ใน app แล้วเข้าใจว่ามันทำอะไร
- [ ] เห็นภาพรวมว่า Hotwire 4 ส่วนทำงานร่วมกันยังไง

## Next: Hackathon!

ถัดไปเราจะเอาทุกอย่างที่เรียนมารวมกันใน hackathon — Turbo Drive, Frames, Streams, Stimulus — สร้าง feature ใหม่ด้วยตัวเอง!
