---
branch: 11-turbo-frames
title: "Turbo Frames — Inline Editing ไม่ต้อง JS"
lang: th
pair: guide-en.md
day: 2
time: "10:00–11:00"
duration: 60min
difficulty: "\U0001F534 Challenge"
prerequisite: 10-day2-start
next: 12-turbo-streams
rails_guide: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
aha_moment: "Inline editing ด้วย HTML tags — ไม่มี JavaScript"
business_rule: "Draft post edit ได้ inline ไม่ต้อง reload"
---

# Turbo Frames — Inline Editing ไม่ต้อง JS

## เปิดเรื่อง: นึกถึง React ก่อน

ใน React คุณ edit inline ยังไง?

`useState` เพื่อ toggle ระหว่าง view mode กับ edit mode. `fetch` เพื่อส่ง data ไป API. DOM manipulation เพื่อ swap component. Re-render logic เพื่ออัพเดท UI. กี่บรรทัด? 30? 50? 100?

วันนี้คุณจะทำเรื่องเดียวกัน — **ไม่ต้องเขียน JavaScript เลย**. ไม่มี useState. ไม่มี fetch. ไม่มี useEffect. แค่ HTML tags.

---

## Turbo Frame คืออะไร?

มันคือ HTML tag:

```html
<turbo-frame id="post_42">
  <!-- content อยู่ตรงนี้ -->
</turbo-frame>
```

แค่นั้น. `<turbo-frame>` บอก browser ว่า **"replace เฉพาะส่วนนี้"** เมื่อ user navigate ภายใน frame, เฉพาะ content ใน frame เปลี่ยน — ส่วนอื่นของหน้าไม่ขยับเลย.

Header ไม่ reload. Sidebar ไม่หาย. Flash messages ไม่กระพริบ. **เฉพาะ frame เปลี่ยน.**

Rails ให้ helper สำหรับสร้าง tag นี้:

```erb
<%= turbo_frame_tag @post do %>
  <!-- content -->
<% end %>
```

ซึ่ง generate เป็น `<turbo-frame id="post_42">` ให้อัตโนมัติ (ใช้ model name + id).

---

## แผนการ

ภาพรวมสิ่งที่เราจะทำ:

1. **show.html.erb** — wrap post content ด้วย `turbo_frame_tag @post`
2. **edit.html.erb** — wrap form ด้วย `turbo_frame_tag @post` (ID เดียวกัน!)
3. User กด "Edit inline" → Turbo fetch หน้า edit → extract เฉพาะ frame ที่ ID ตรง → **form โผล่แทนที่ content ใน frame**
4. User submit → controller redirect กลับ show → Turbo extract frame → **content อัพเดท**

ทั้งหมดนี้ไม่ reload หน้า. ไม่มี JavaScript. เป็นแค่ HTML attributes.

> **Business rule:** เฉพาะ **draft posts** เท่านั้นที่ edit ได้ inline. Published posts เป็น immutable. Comments edit ไม่ได้เลย.

---

## Step-by-step

### Step 1: Wrap post content ใน show.html.erb

เปิด `app/views/posts/show.html.erb` แล้ว wrap ส่วน post content ด้วย turbo frame:

```erb
<%= turbo_frame_tag @post do %>
  <h1><%= @post.title %></h1>
  <div><%= @post.body %></div>

  <% if @post.draft? && @post.user == current_user %>
    <%= link_to "Edit inline", edit_post_path(@post) %>
  <% end %>
<% end %>
```

สิ่งสำคัญ: **Edit link ต้องอยู่ข้างใน frame** ถ้า link อยู่นอก frame, Turbo จะไม่ intercept click — มันจะ full page navigate แทน.

### Step 2: Wrap form ใน edit.html.erb

เปิด `app/views/posts/edit.html.erb` แล้ว wrap form ด้วย **matching** turbo frame:

```erb
<%= turbo_frame_tag @post do %>
  <%= render "form", post: @post %>

  <%= link_to "Cancel", post_path(@post) %>
<% end %>
```

**KEY:** `turbo_frame_tag @post` ใน show และ edit ต้อง generate **ID เดียวกัน** ถ้า show มี `id="post_42"` แต่ edit มี `id="edit_post_42"` — มันจะไม่ทำงาน.

### Step 3: Edit link ต้องอยู่ใน frame

ตรวจสอบว่า link "Edit inline" อยู่ **ข้างใน** `turbo_frame_tag` block ใน show.html.erb. ถ้ามันอยู่ข้างนอก Turbo จะปล่อยให้ browser navigate ปกติ (full page reload).

### Step 4: Cancel link

Cancel link ใน edit.html.erb ต้องอยู่ **ข้างใน** frame เช่นกัน. เมื่อ user กด Cancel, Turbo จะ fetch show page, extract frame, แล้ว replace form กลับเป็น content เดิม.

```erb
<%= link_to "Cancel", post_path(@post) %>
```

ง่ายมาก. แค่ link ธรรมดา. Turbo จัดการให้หมด.

### Step 5: ทดสอบ

1. ไปที่ draft post ของคุณ
2. กด "Edit inline"
3. Form ต้องปรากฏ **ในที่เดิม** — ไม่ redirect ไปหน้าอื่น
4. แก้ title หรือ body
5. กด submit
6. Content อัพเดท **ในที่เดิม** — ไม่ reload หน้า
7. กด "Edit inline" อีกครั้ง แล้วกด "Cancel"
8. Form หายไป กลับเป็น content เดิม

---

## KEY WARNING: Frame IDs ต้อง Match

นี่คือ **error ที่พบบ่อยที่สุด** ของ step นี้.

`turbo_frame_tag @post` generate `<turbo-frame id="post_42">` — ทั้งใน show.html.erb และ edit.html.erb ต้อง generate **ID เดียวกัน**.

ถ้า ID ไม่ตรง:
- Turbo fetch หน้า edit มา
- หา `<turbo-frame id="post_42">` ไม่เจอ
- **ไม่มีอะไรเกิดขึ้น** (หรือ frame หายไปเลย)

เปิด DevTools → Network tab → ดู response ของ edit request → ตรวจว่า `<turbo-frame id="...">` ตรงกัน.

---

## เบื้องหลัง: มันทำงานยังไง?

1. User click link ที่อยู่ **ภายใน** `<turbo-frame>`
2. Turbo **intercept** click (ไม่ให้ browser navigate)
3. Turbo ส่ง **fetch request** ไปหา URL ของ link นั้น
4. Server respond ด้วย full HTML page (ปกติ)
5. Turbo **extract** เฉพาะ `<turbo-frame>` ที่ ID ตรงกัน จาก response
6. Turbo **replace** content ใน frame เดิม ด้วย content จาก response
7. ส่วนอื่นของหน้า **ไม่ถูกแตะต้อง**

นี่คือเหตุผลว่าทำไม:
- ID ต้องตรงกัน (step 5 จะหาไม่เจอ)
- Link ต้องอยู่ใน frame (step 1 จะไม่ intercept)
- Controller ไม่ต้องเปลี่ยนอะไร (server respond ด้วย full page ปกติ)

---

## Checkpoints

### Checkpoint 1 (green)

`turbo_frame_tag @post` generate HTML อะไร?

attribute ไหนที่ทำให้ Turbo รู้ว่าต้อง replace ส่วนไหนของหน้า?

> ลองเปิด DevTools → Inspect element → ดู tag ที่ generate ออกมา

---

### Checkpoint 2 (yellow)

ถ้า frame ID ใน show.html.erb เป็น `post_42` แต่ใน edit.html.erb เป็น `edit_post` — จะเกิดอะไร?

> ลองทดสอบ: เปลี่ยน edit ให้ใช้ `turbo_frame_tag "wrong_id"` แล้วดูว่าเกิดอะไร

---

### Checkpoint 3 (red)

ถ้าต้องทำ inline editing เดียวกันนี้ใน React:

- ต้องใช้ `useState` กี่ตัว?
- ต้อง `fetch` กี่ครั้ง?
- ต้อง manage DOM ยังไง?
- Re-render logic ซับซ้อนแค่ไหน?

เปรียบเทียบกับสิ่งที่คุณเพิ่งทำ — **เพิ่ม HTML tag 2 จุด แล้วจบ**.

---

## ติดอยู่? อ่านตรงนี้

Step นี้เป็น step ที่ยากที่สุดของ workshop. ไม่ต้องกังวลถ้าติด — ทุกคนติดตรงนี้.

### ถ้า click Edit แล้ว full page reload

- Edit link อยู่ **นอก** `turbo_frame_tag` block → ย้ายเข้าไปข้างใน
- Frame IDs ไม่ match → เปิด DevTools ตรวจ `<turbo-frame id="...">` ทั้ง 2 หน้า
- Turbo ไม่ได้ถูก import → ตรวจ `application.js` ว่ามี Turbo

### ถ้า form ไม่โผล่

- edit.html.erb ไม่มี `turbo_frame_tag` → เพิ่ม `turbo_frame_tag @post` ครอบ form
- Frame ID ใน edit ไม่ตรงกับ show → ใช้ `turbo_frame_tag @post` ทั้งคู่ (ไม่ใช่ hardcode string)
- DevTools → Network → ดู response ของ edit request → หา `<turbo-frame>` tag

### ถ้า submit แล้วไม่กลับ show

- Controller ต้อง `redirect_to @post` ไม่ใช่ `render :show`
- ถ้า `render` → Turbo จะได้ response ที่มี status 200 แต่ไม่ redirect → frame ค้าง
- ตรวจ `posts_controller.rb` method `update`

### ถ้า Cancel ไม่ทำงาน

- Cancel link ต้องอยู่ **ข้างใน** `turbo_frame_tag` block ใน edit.html.erb
- ถ้าอยู่นอก frame, click จะ full page navigate

### ถ้า content นอก frame หายไป

- ตรวจว่าคุณ wrap **เฉพาะส่วนที่ต้อง edit** ไม่ใช่ทั้งหน้า
- Comment section, tags, author info ควรอยู่ **นอก** frame

### ถ้า edit published post ได้

- ตรวจ authorization — เฉพาะ draft posts เท่านั้นที่ควรมี Edit link
- Controller ควร check `@post.draft?` ก่อน allow edit

### ถ้าไม่มีอะไรทำงานเลย

- เริ่มใหม่จาก minimal case: ใส่ `turbo_frame_tag @post` ใน show + edit แค่ 2 จุด
- ทำให้ basic case ทำงานก่อน แล้วค่อยเพิ่ม Cancel, styling, authorization

---

## สิ่งที่ได้เรียนรู้

- `turbo_frame_tag` สร้าง `<turbo-frame>` ที่ scope การ navigation ไว้เฉพาะ frame
- Frame IDs ต้อง match ระหว่าง source page และ target page
- Links และ forms ภายใน frame ถูก Turbo intercept อัตโนมัติ
- ไม่ต้องเขียน JavaScript เลย — ทุกอย่างเป็น HTML attributes
- Business rule: เฉพาะ draft posts edit inline ได้

## ต่อไป

Step ถัดไป: **Turbo Streams** — real-time updates ที่ push จาก server มาหา browser. ถ้า Turbo Frames คือ "user กด แล้ว frame เปลี่ยน" Turbo Streams คือ "server push แล้ว หน้าเปลี่ยนเอง".
