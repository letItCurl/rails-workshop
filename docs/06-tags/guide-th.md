---
branch: 06-tags
title: "Tags — has_many :through"
lang: th
pair: guide-en.md
day: 1
time: "13:50–14:35"
duration: 45min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 05-polish
next: 07-rich-text-images
rails_guide: https://guides.rubyonrails.org/association_basics.html#the-has-many-through-association
aha_moment: "has_many :through — สอง lines จัดการทุกอย่าง"
business_rule: "โพสต์มีหลาย tags, tag อยู่ในหลายโพสต์"
---

# Tags — has_many :through

Step นี้คือหัวใจของ workshop เลย เพราะ join table + `has_many :through` คือ pattern ที่ใช้ได้ทุกที่ ไม่ว่าจะ Rails หรือไม่ก็ตาม

---

## 1. Business Question

โพสต์ 100 อัน ไม่มีหมวดหมู่ จะหายังไง?

ลองคิดดูก่อน — ถ้า user อยากหาโพสต์เกี่ยวกับ "Rails" ล่ะ? ต้อง scroll ดูทีละอัน?

**Pause 3 นาที:** วาด relationship ระหว่าง Post กับ Tag บนกระดาษ ไม่ต้องคิดเรื่อง code เลย แค่คิดว่า data มันเชื่อมกันยังไง

---

## 2. Why — ทำไมต้อง Join Table?

ความคิดแรกที่หลายคนมีคือ "เก็บ tags เป็น JSON array ใน Post สิ" — เช่น `["Rails", "Ruby", "Testing"]`

ปัญหาคือ:
- Query ยาก — `WHERE tags LIKE '%Rails%'` ไม่ reliable
- ไม่ scale — ถ้าอยาก rename tag ต้อง update ทุก row
- ไม่มี index ที่ดี — slow query เมื่อ data เยอะ

**Join table คือวิธีที่ถูก** เพราะ relational database ถูกออกแบบมาให้ JOIN ข้อมูลระหว่าง tables

---

## 3. Hands-on: สร้าง Tag Model

```bash
rails g scaffold Tag name:string
rails db:migrate
```

เปิด `db/schema.rb` ดู — ตอนนี้เรามี `tags` table แล้ว มี column `name` อย่างเดียว ง่ายมาก

---

## 4. Join Table: PostTag

ตรงนี้คือ key — เราต้องมี table ตรงกลางที่เชื่อม Post กับ Tag

```bash
rails g model PostTag post:references tag:references
rails db:migrate
```

เปิด `db/schema.rb` อีกครั้ง — `post_tags` table มีแค่ `post_id` กับ `tag_id` (บวก id กับ timestamps) แค่นั้นเอง ไม่มี business data ใน table นี้ มันมีหน้าที่แค่ "เชื่อม"

---

## 5. Wire Models

เปิด `app/models/post.rb`:

```ruby
has_many :post_tags
has_many :tags, through: :post_tags
```

เปิด `app/models/tag.rb`:

```ruby
has_many :post_tags
has_many :posts, through: :post_tags
```

เปิด `app/models/post_tag.rb`:

```ruby
belongs_to :post
belongs_to :tag
```

สอง lines ใน Post, สอง lines ใน Tag — แค่นี้ Rails จัดการ JOIN ให้หมดเลย

---

## 6. Console SQL — ดูว่า Rails ทำอะไร

เปิด `rails console` แล้วลอง:

```ruby
post = Post.first
tag = Tag.create!(name: "Rails")

# เพิ่ม tag ให้ post
post.tags << tag

# ดู tags ของ post — สังเกต SQL ที่ Rails generate
post.tags

# กลับทาง — ดู posts ของ tag
tag.posts
```

**สังเกต SQL** ที่ console แสดง — จะเห็น `INNER JOIN post_tags ON ...` นี่คือสิ่งที่ `has_many :through` ทำให้เรา ไม่ต้องเขียน SQL เอง

---

## Checkpoint 1 (Green)

ปิด editor ตอบ 3 คำถามนี้ (ไม่ดู code):

1. `post_tags` table มี columns อะไรบ้าง?
2. ทำไมต้องมี table แยก? ทำไมไม่เก็บใน Post ตรง ๆ?
3. ถ้า post มี 3 tags → `post_tags` มีกี่ rows?

---

## 7. Form: เลือก Tags

ใน `app/views/posts/_form.html.erb` เพิ่ม:

```erb
<div>
  <%= form.label :tag_ids, "Tags" %>
  <%= form.collection_check_boxes(:tag_ids, Tag.all, :id, :name) do |b| %>
    <label class="inline-flex items-center mr-4">
      <%= b.check_box class: "rounded border-gray-300" %>
      <span class="ml-2"><%= b.text %></span>
    </label>
  <% end %>
</div>
```

ใน `posts_controller.rb` อย่าลืม permit:

```ruby
params.require(:post).permit(:title, :body, :published, tag_ids: [])
```

สำคัญมาก: `tag_ids: []` ต้องเป็น array — ถ้าเขียน `:tag_ids` เฉย ๆ จะ unpermitted

---

## 8. Show Tags — Tailwind Badges

ใน `app/views/posts/show.html.erb`:

```erb
<div class="flex flex-wrap gap-2 mt-2">
  <% @post.tags.each do |tag| %>
    <span class="inline-block bg-indigo-100 text-indigo-800 text-xs font-semibold px-2.5 py-0.5 rounded-full">
      <%= tag.name %>
    </span>
  <% end %>
</div>
```

---

## 9. Seed Tags

ใน `db/seeds.rb` เพิ่ม:

```ruby
%w[Ruby Rails Database Testing Hotwire].each do |name|
  Tag.find_or_create_by!(name: name)
end
```

แล้ว `rails db:seed`

---

## Checkpoint 2 (Yellow)

Predict SQL สำหรับ query นี้ — **เขียนบนกระดาษก่อน** อย่าเปิด console:

```ruby
Post.joins(:tags).where(tags: { name: "Rails" })
```

คิดว่า Rails จะ generate SQL อะไร? table ไหน JOIN กับ table ไหน? เขียนเสร็จแล้วค่อยเปิด console เช็ค

---

## Checkpoint 3 (Red)

เขียน test ตั้งแต่ศูนย์ที่พิสูจน์ว่า association ทำงานสองทาง:

- สร้าง post, สร้าง tag
- เพิ่ม tag ให้ post
- Assert ว่า `post.tags` include tag นั้น
- Assert ว่า `tag.posts` include post นั้น

ลองเขียนเอง ถ้าติดค่อยถาม mentor

---

## 10. Reflection

`has_many :through` ใช้ที่ไหนอีกได้บ้าง?

- **Student - Course:** student เรียนหลาย course, course มีหลาย students → join table: `enrollments`
- **Order - Product:** order มีหลาย products, product อยู่ในหลาย orders → join table: `order_items` (มี quantity ด้วย!)
- **User - Role:** user มีหลาย roles, role มีหลาย users → join table: `user_roles`

ลองคิดดูว่าใน React projects ที่เคยทำ มี many-to-many relationship ตรงไหนบ้าง? จัดการยังไง? ต่างจาก Rails approach ยังไง?

---

## Self-check

- [ ] Tag scaffold ทำงาน CRUD ได้
- [ ] `post_tags` table มี foreign keys ถูกต้อง
- [ ] `Post.first.tags` return tags ได้
- [ ] `Tag.first.posts` return posts ได้ (bidirectional)
- [ ] Form มี checkboxes เลือก tags ได้
- [ ] `tag_ids` permitted เป็น array
- [ ] Show page แสดง tag badges
- [ ] Seeds สร้าง 5 tags
- [ ] ผ่าน Checkpoint 1 (Green)
- [ ] ผ่าน Checkpoint 2 (Yellow)
- [ ] ผ่าน Checkpoint 3 (Red)

---

## Next Up

Step ถัดไป: **07-rich-text-images** — เราจะใช้ Action Text กับ Active Storage ให้โพสต์มี rich content กับรูปภาพได้
