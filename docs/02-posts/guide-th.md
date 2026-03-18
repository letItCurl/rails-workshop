---
branch: 02-posts
title: "Posts — อ่าน Routes, เห็น SQL"
lang: th
pair: guide-en.md
day: 1
time: "10:30–11:00"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 01-foundation
next: 03-auth
rails_guide: https://guides.rubyonrails.org/routing.html
aha_moment: "database IS the design — อ่านแอปทั้งหมดจาก 2 ไฟล์"
business_rule: "Post.all → SELECT * FROM posts — ไม่มี magic"
---

# 🔍 อ่านแอปจาก 2 ไฟล์

ตอนนี้คุณมีแอปที่ทำงานได้ สร้างโพสต์ได้ แก้ไขได้ ลบได้ แต่ลองถามตัวเองว่า... คุณ *เข้าใจ* มันจริงมั้ย?

ถ้ามีคนโยน Rails app มาให้คุณ — โค้ดหลายพันบรรทัด controller เป็นสิบ model เป็นสิบ — คุณจะเริ่มอ่านจากไหน?

คำตอบคือ **2 ไฟล์**: `config/routes.rb` กับ `db/schema.rb`

ถ้าคุณอ่านสองไฟล์นี้ได้ คุณเข้าใจแอปทั้งหมด

---

## อ่าน Routes

เปิด terminal แล้ว run:

```bash
rails routes
```

สิ่งที่คุณเห็นคือ **ทุก URL** ที่แอปรับได้ ทุก HTTP method (GET, POST, PATCH, DELETE) ทุก controller action

เปิด `config/routes.rb` ดู:

```ruby
resources :posts
```

บรรทัดเดียว สร้าง 7 routes ทั้ง index, show, new, create, edit, update, destroy

**คิดดู:** ใน React/Next คุณต้องสร้างไฟล์กี่ไฟล์ เพื่อให้ได้ routes เท่านี้?

---

## อ่าน Schema

เปิด `db/schema.rb`:

```ruby
create_table "posts", force: :cascade do |t|
  t.string "title"
  t.text "body"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

นี่คือ **database ทั้งหมด** ของแอปคุณ ทุก table ทุก column อยู่ในไฟล์เดียว

Routes บอกว่าแอปทำอะไรได้ Schema บอกว่าแอปเก็บอะไร **สองไฟล์นี้คือ blueprint ทั้งหมด**

---

## ดู SQL ที่ซ่อนอยู่

เปิด rails console:

```bash
rails console
```

ลอง run:

```ruby
Post.all
```

ดู terminal — เห็น SQL มั้ย?

```sql
SELECT "posts".* FROM "posts"
```

ActiveRecord ไม่ได้ทำเวทมนตร์ มันแค่เขียน SQL ให้คุณ ทุกครั้งที่คุณเรียก method มัน generate SQL string แล้ว execute กับ database

ลองต่อ:

```ruby
Post.create(title: "test", body: "hello world")
```

ดู SQL — มี `INSERT INTO "posts"` ออกมา

```ruby
Post.where(title: "test")
```

ดู SQL — มี `WHERE "posts"."title" = $1` ออกมา

```ruby
Post.first
```

ดู SQL — มี `LIMIT 1` ออกมา

**ทุก method = SQL ที่อ่านได้** ไม่มี magic ซ่อนอยู่

---

## 🧪 ลองตอบดู

1. **`resources :posts` สร้างกี่ routes?** (นับจาก `rails routes`)
2. **`Post.all` generate SQL อะไร?**
3. **ถ้าคุณต้องอ่าน Rails app ที่ไม่เคยเห็น คุณเปิดไฟล์อะไรก่อน?**

**คุยกับคนข้างๆ:** "Read the routes, know the database" หมายความว่ายังไง?

---

## ✅ ก่อนไปต่อ

- [ ] อ่าน `config/routes.rb` แล้วเข้าใจว่า `resources :posts` สร้างอะไร
- [ ] อ่าน `db/schema.rb` แล้วเข้าใจ structure ของ posts table
- [ ] เห็น SQL ใน rails console ที่ ActiveRecord generate
- [ ] อธิบายได้ว่า "Read the routes, know the database" หมายความว่าอะไร

---

## ➡️ ต่อไป: Branch `03-auth`

ใครก็โพสต์ได้ ใครก็แก้ได้ ใครก็ลบได้ — แต่ *ใคร* โพสต์ล่ะ? เราต้องมี users
