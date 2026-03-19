---
branch: 06-tags-deep-dive
title: "Deep Dive — has_many :through ทำงานยังไงจริงๆ"
lang: th
pair: guide-en.md
day: 1
time: "14:20–14:35"
duration: 15min
difficulty: 🟡 Recipe + Why
prerequisite: 06-tags
next: 07-rich-text-images
rails_guide: https://guides.rubyonrails.org/association_basics.html#the-has-many-through-association
aha_moment: "ActiveRecord chain = SQL JOINs — ทุก method คือ SQL ที่อ่านได้"
business_rule: "ไม่มี business rule ใหม่ — step นี้คือทำความเข้าใจ"
---

# 🔬 has_many :through ทำงานยังไงจริงๆ?

คุณเพิ่งสร้าง tags ด้วย has_many :through มันทำงาน แต่คุณเข้าใจจริงมั้ยว่า **ข้างใน** มันเกิดอะไรขึ้น?

Step นี้ไม่มีโค้ดใหม่ — เราจะ **แกะ** สิ่งที่เพิ่งสร้าง ดู SQL ดู tables ดูว่า ActiveRecord ทำอะไรให้คุณ

---

## Tables ทั้ง 3 หน้าตาเป็นยังไง

เปิด `db/schema.rb` แล้วมองแค่ 3 tables:

```
posts                post_tags              tags
┌──────────────┐     ┌──────────────┐      ┌──────────────┐
│ id           │     │ id           │      │ id           │
│ title        │     │ post_id  ──────────→│ name         │
│ body         │←──────── post_id   │      │ created_at   │
│ published    │     │ tag_id   ──────────→│ updated_at   │
│ user_id      │     │ created_at   │      └──────────────┘
│ created_at   │     │ updated_at   │
│ updated_at   │     └──────────────┘
└──────────────┘
```

**สังเกต:** `post_tags` ไม่มี `name` ไม่มี `body` ไม่มีอะไรนอกจาก `post_id` กับ `tag_id` มันเป็นแค่ **ตัวเชื่อม**

ลองใส่ข้อมูลจริง:

```
posts                post_tags              tags
┌────┬───────────┐   ┌────┬─────┬──────┐   ┌────┬──────────┐
│ id │ title     │   │ id │post │tag   │   │ id │ name     │
├────┼───────────┤   │    │_id  │_id   │   ├────┼──────────┤
│  1 │ Deadlines │   ├────┼─────┼──────┤   │  1 │ Ruby     │
│  2 │ Meetings  │   │  1 │  1  │  1   │   │  2 │ Rails    │
│  3 │ Simple    │   │  2 │  1  │  2   │   │  3 │ Database │
└────┴───────────┘   │  3 │  2  │  3   │   │  4 │ Testing  │
                     │  4 │  3  │  1   │   │  5 │ Hotwire  │
                     │  5 │  3  │  2   │   └────┴──────────┘
                     └────┴─────┴──────┘
```

**อ่าน:** Post 1 ("Deadlines") มี tag Ruby (row 1) กับ Rails (row 2) Post 3 ("Simple") มี tag Ruby (row 4) กับ Rails (row 5)

**ถามกลุ่ม:** Post 2 ("Meetings") มี tag อะไร? Tag "Ruby" อยู่ในโพสต์ไหนบ้าง?

---

## has_many :through แต่ละ argument ทำอะไร

เปิด `app/models/post.rb` ดูสอง lines นี้:

```ruby
has_many :post_tags, dependent: :destroy
has_many :tags, through: :post_tags
```

**Line 1:** `has_many :post_tags`
- บอก Rails ว่า: "Post มีหลาย PostTag records"
- Rails รู้ว่าต้องหา `post_id` ใน `post_tags` table
- `dependent: :destroy` = ลบ post → ลบ post_tags ที่เชื่อมกับมันด้วย (แต่ไม่ลบ tag)

**Line 2:** `has_many :tags, through: :post_tags`
- บอก Rails ว่า: "Post มีหลาย Tags **ผ่าน** PostTag"
- `:tags` = ชื่อ association (ตรงกับ model Tag)
- `through: :post_tags` = ไปหา tags โดย **ผ่าน** post_tags table
- Rails จะทำ JOIN ให้อัตโนมัติ

**เปิด tag.rb ดู — เหมือนกันแต่กลับทาง:**

```ruby
has_many :post_tags, dependent: :destroy
has_many :posts, through: :post_tags
```

---

## ดู SQL จริงที่ Rails สร้าง

เปิด `rails console` แล้วลองทีละอัน:

### 1. หา tags ของ post

```ruby
post = Post.first
post.tags
```

**SQL ที่ได้:**
```sql
SELECT "tags".* FROM "tags"
INNER JOIN "post_tags" ON "tags"."id" = "post_tags"."tag_id"
WHERE "post_tags"."post_id" = $1
```

**อ่าน SQL:** เริ่มจาก `tags` table → JOIN กับ `post_tags` (เชื่อม tags.id = post_tags.tag_id) → filter เฉพาะ post_tags ที่ post_id ตรงกับ post ของเรา

### 2. หา posts ของ tag (กลับทาง)

```ruby
tag = Tag.first
tag.posts
```

**SQL ที่ได้:**
```sql
SELECT "posts".* FROM "posts"
INNER JOIN "post_tags" ON "posts"."id" = "post_tags"."post_id"
WHERE "post_tags"."tag_id" = $1
```

**เหมือนกัน แต่กลับทาง!** เริ่มจาก `posts` → JOIN กับ `post_tags` → filter ตาม tag_id

### 3. เพิ่ม tag ให้ post

```ruby
post.tags << Tag.find_by(name: "Database")
```

**SQL ที่ได้:**
```sql
INSERT INTO "post_tags" ("post_id", "tag_id", "created_at", "updated_at")
VALUES ($1, $2, $3, $4)
```

**ไม่ได้แตะ posts table หรือ tags table เลย!** แค่สร้าง row ใหม่ใน `post_tags`

### 4. Query ข้าม table

```ruby
Post.joins(:tags).where(tags: { name: "Rails" })
```

**SQL ที่ได้:**
```sql
SELECT "posts".* FROM "posts"
INNER JOIN "post_tags" ON "post_tags"."post_id" = "posts"."id"
INNER JOIN "tags" ON "tags"."id" = "post_tags"."tag_id"
WHERE "tags"."name" = $1
```

**สอง JOINs!** posts → post_tags → tags เพราะ posts กับ tags ไม่ได้เชื่อมกันตรงๆ ต้องผ่าน post_tags

---

## Pattern เดียวกันอยู่ทุกที่

ลองดู associations ที่มีอยู่แล้วในแอป:

```ruby
User.first.posts              # has_many :posts
User.first.posts.first.comments  # has_many :comments (through post)
User.first.comments           # has_many :comments (direct)
```

**ลอง chain ยาวขึ้น:**

```ruby
# หา tags ทั้งหมดที่ User คนแรกเคยใช้
User.first.posts.includes(:tags).flat_map(&:tags).uniq.map(&:name)
```

**ลองอีก:**

```ruby
# หา users ทั้งหมดที่เคยโพสต์ด้วย tag "Rails"
User.joins(posts: :tags).where(tags: { name: "Rails" }).distinct
```

**SQL ที่ได้:**
```sql
SELECT DISTINCT "users".* FROM "users"
INNER JOIN "posts" ON "posts"."user_id" = "users"."id"
INNER JOIN "post_tags" ON "post_tags"."post_id" = "posts"."id"
INNER JOIN "tags" ON "tags"."id" = "post_tags"."tag_id"
WHERE "tags"."name" = $1
```

**สาม JOINs!** users → posts → post_tags → tags ActiveRecord chain ทุกอันคือ SQL JOIN ที่อ่านได้

---

## เปรียบเทียบ: ถ้าไม่มี has_many :through

สมมติคุณเก็บ tags เป็น JSON array ใน posts table:

```json
{ "title": "Deadlines", "tags": ["Ruby", "Rails"] }
```

**ปัญหา:**
- หาโพสต์ที่มี tag "Ruby"? → `WHERE tags @> '["Ruby"]'` (PostgreSQL-specific, ช้า, ไม่มี index)
- หา tag ทั้งหมดที่มี? → ต้อง scan ทุก row แล้ว extract unique values
- เปลี่ยนชื่อ tag? → ต้อง update ทุก row ที่มี tag นั้น
- นับโพสต์ต่อ tag? → ช้ามากเมื่อ data เยอะ

**has_many :through:**
- หาโพสต์ที่มี tag "Ruby"? → `Post.joins(:tags).where(tags: { name: "Ruby" })` (indexed, เร็ว)
- หา tag ทั้งหมด? → `Tag.all` (แยก table, O(1))
- เปลี่ยนชื่อ tag? → `Tag.find_by(name: "Ruby").update(name: "Ruby Lang")` (update 1 row)
- นับโพสต์ต่อ tag? → `Tag.joins(:posts).group(:name).count` (SQL GROUP BY, เร็ว)

---

## 🧪 ลองตอบดู

1. **`has_many :tags, through: :post_tags` — `through` ทำอะไร?**
2. **ทำไม `post.tags << tag` ถึงไม่แก้ posts table หรือ tags table?**
3. **`Post.joins(:tags).where(tags: { name: "Rails" })` มีกี่ JOINs? ผ่าน table ไหนบ้าง?**
4. **ถ้า User model มี `has_many :posts` แล้ว Post มี `has_many :tags, through: :post_tags` — จะหา tags ทั้งหมดของ user ยังไง?**

**คุยกับคนข้างๆ:** ลองคิดถึงระบบจริงที่ใช้ has_many :through — ร้านอาหารกับ menu items? นักเรียนกับวิชา? คนกับ roles?

---

## ✅ ก่อนไปต่อ

- [ ] อธิบายได้ว่า join table ทำอะไร ทำไมต้องมี
- [ ] อ่าน SQL ที่ ActiveRecord สร้างจาก has_many :through ได้
- [ ] เข้าใจว่า `through:` บอก Rails ให้ JOIN ผ่าน table ไหน
- [ ] เข้าใจว่าทำไม JSON array ไม่ scale
- [ ] บอกได้ว่า pattern นี้ใช้ที่ไหนได้อีก

---

## ➡️ ต่อไป: Branch `07-rich-text-images`

โพสต์แบบ text ธรรมดามันน่าเบื่อ — user อยากได้ rich text กับรูป คิดว่าต้องทำกี่วัน? 😏
