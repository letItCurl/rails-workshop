---
branch: 01-foundation
title: "Foundation — แอปแรกของคุณ"
lang: th
pair: guide-en.md
day: 1
time: "9:50–10:30"
duration: 40min
difficulty: "\U0001F7E2 Recipe"
prerequisite: 00-start
next: 02-posts
rails_guide: https://guides.rubyonrails.org/getting_started.html
aha_moment: "3 commands = working app"
business_rule: "โพสต์เปิดอ่านได้ทุกคน ใครก็สร้างได้"
---

# Foundation — แอปแรกของคุณ

## เคยเริ่มโปรเจคตั้งแต่ศูนย์มั้ย?

คุณเคยเริ่มโปรเจค React/Next มั้ย? ต้อง setup routing, สร้าง API endpoint, เขียน migration, configure database, เชื่อม ORM... กว่าจะเห็นหน้าแรกบนจอก็ผ่านไปเป็นชั่วโมง

ใน Rails เราจะทำทุกอย่างนั้นด้วย 3 คำสั่ง

ลองตั้งคำถามกับตัวเองก่อน:

> **ถ้าคำสั่งเดียวสร้างแอปได้ คุณจะสร้างอะไร?**

วันนี้เราจะสร้างแอปชื่อ **Oddly Honest** — บล็อกที่ใครก็โพสต์ได้ ใครก็อ่านได้ ตรงไปตรงมา

---

## มาเริ่มกันเลย

### 1. สร้างแอป Rails

```bash
rails new . -d postgresql --css tailwind --name oddly_honest
```

คำสั่งนี้จะสร้างโครงสร้างแอปทั้งหมดให้เลย — ตั้งแต่ไฟล์ config, database.yml, Gemfile, ไปจนถึง Tailwind CSS พร้อมใช้

### 2. สร้าง Database

```bash
rails db:create
```

คำสั่งนี้สร้าง database ใน PostgreSQL ให้อัตโนมัติ ไม่ต้องเปิด psql เอง

### 3. สร้าง Scaffold สำหรับ Post

```bash
rails g scaffold Post title:string body:text
```

คำสั่งเดียวนี้สร้างให้ทุกอย่าง:

- **Model** (`app/models/post.rb`) — ตัวแทนข้อมูลในฐานข้อมูล
- **Controller** (`app/controllers/posts_controller.rb`) — จัดการ request ทั้ง 7 actions (index, show, new, create, edit, update, destroy)
- **Views** (`app/views/posts/`) — หน้าเว็บสำหรับแสดงผล, สร้าง, แก้ไข
- **Migration** (`db/migrate/..._create_posts.rb`) — คำสั่งสร้างตาราง posts ใน database
- **Routes** — เส้นทาง URL ทั้งหมดของ posts

### 4. Run Migration

```bash
rails db:migrate
```

### 5. เปิด Server

```bash
bin/dev
```

### 6. เปิดเบราว์เซอร์

ไปที่ [http://localhost:3000/posts](http://localhost:3000/posts)

ลองสร้างโพสต์, แก้ไข, ลบดู — ครบทุก CRUD เลย!

---

## Scaffold สร้างอะไรให้บ้าง?

ลองเปิดดูไฟล์เหล่านี้:

| ไฟล์ | หน้าที่ |
|---|---|
| `app/models/post.rb` | Model — ตัวแทนข้อมูล |
| `app/controllers/posts_controller.rb` | Controller — จัดการ logic |
| `app/views/posts/` | Views — หน้าเว็บ |
| `db/migrate/..._create_posts.rb` | Migration — สร้างตาราง |
| `config/routes.rb` | Routes — เส้นทาง URL |

เปิดไฟล์ `config/routes.rb` ดู จะเห็น:

```ruby
resources :posts
```

บรรทัดเดียวนี้สร้าง routes ให้ 7 เส้นทาง ลอง run `rails routes` ดูได้

---

## Checkpoint Questions

### 1. นับคำสั่ง
จากศูนย์จนถึงแอปทำงานได้ ใช้กี่คำสั่ง?

### 2. เทียบกับ React
ถ้าจะทำ CRUD app แบบเดียวกันใน React/Next ต้องใช้เวลาเท่าไหร่?

### 3. routes.rb มีอะไร?
เปิด `config/routes.rb` แล้วบอกว่าเห็นอะไรบ้าง?

---

## Self-Check

- [ ] แอปรันได้ที่ localhost:3000/posts
- [ ] สร้างโพสต์ใหม่ได้
- [ ] แก้ไขโพสต์ได้
- [ ] ลบโพสต์ได้
- [ ] เปิด `config/routes.rb` แล้วเข้าใจว่า `resources :posts` ทำอะไร

---

## ต่อไป: 02-posts

ตอนนี้เรามี CRUD ครบแล้ว แต่โพสต์ยังไม่มี validation เลย — ใครจะส่งโพสต์เปล่าก็ได้ ใน step ถัดไปเราจะทำให้แอปฉลาดขึ้น เพิ่ม validation และปรับแต่ง views ให้สวยงาม
