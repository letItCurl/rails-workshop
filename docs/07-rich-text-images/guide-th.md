---
branch: 07-rich-text-images
title: "Rich Text + Images — ของฟรีจาก Rails"
lang: th
pair: guide-en.md
day: 1
time: "14:50–15:20"
duration: 30min
difficulty: "\U0001F7E2 Recipe"
prerequisite: 06-tags-deep-dive
next: 08-team-survival
rails_guide:
  - https://guides.rubyonrails.org/action_text_overview.html
  - https://guides.rubyonrails.org/active_storage_overview.html
aha_moment: "Rich text + file uploads — zero custom code"
business_rule: "โพสต์มี rich text body + cover image"
---

# Rich Text + Images — ของฟรีจาก Rails

## Business Question

"text ธรรมดาน่าเบื่อ user อยากได้ rich text กับรูป คิดว่าต้องทำกี่วัน?"

ถ้าเป็น framework อื่น คำตอบอาจจะ "สัก 2–3 วันมั้ง" แต่ Rails มีของฟรีให้เรา ทำได้ภายในไม่กี่นาที มาดูกัน

---

## 1. Install Action Text

Action Text เป็น feature ที่ Rails มีมาให้เลย ไม่ต้อง install gem เพิ่ม แค่รัน:

```bash
rails action_text:install
rails db:migrate
```

แค่สอง commands นี้ Rails สร้างอะไรให้เราบ้าง?

- **action_text_rich_texts table** — ตารางเก็บ rich text content แยกจาก model หลัก
- **Trix editor JS** — rich text editor ที่ Rails bundle มาให้ พร้อม bold, italic, links, lists ทุกอย่าง
- **Active Storage migration** — ถ้ายังไม่มี จะสร้างให้ด้วย (เพราะ rich text รองรับ embedded images)

### เปลี่ยน Post model

เปิด `app/models/post.rb` แล้วเปลี่ยนจาก text field ธรรมดาเป็น rich text:

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  # ... existing code ...
end
```

ลบ `body` column เดิมออกไม่ต้อง — `has_rich_text` จะใช้ตาราง `action_text_rich_texts` แทน แต่ถ้าอยากเคลียร์ ก็สร้าง migration ลบ column เดิมได้

### Update form

เปิด `app/views/posts/_form.html.erb` แล้วเปลี่ยน:

```erb
<%= form.rich_text_area :body %>
```

แค่นี้เลย! ลองเปิด browser ดู — จะเห็น **WYSIWYG editor เต็มรูปแบบ** ปรากฏขึ้นมา พร้อม toolbar สำหรับ bold, italic, headings, lists, links ทุกอย่าง

---

## 2. Install Active Storage

ต่อมาเราอยากให้ Post มี cover image ได้ด้วย Active Storage คือคำตอบ:

```bash
rails active_storage:install
rails db:migrate
```

> หมายเหตุ: ถ้า `rails action_text:install` สร้าง Active Storage migration ให้แล้ว ขั้นตอนนี้อาจไม่ต้องทำ แต่รันซ้ำก็ไม่เป็นไร

### เพิ่ม attachment ใน Post model

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  has_one_attached :cover_image
  # ... existing code ...
end
```

### เพิ่ม file field ใน form

```erb
<div>
  <%= form.label :cover_image %>
  <%= form.file_field :cover_image %>
</div>
```

### แสดงรูปใน show page

```erb
<% if @post.cover_image.attached? %>
  <%= image_tag @post.cover_image %>
<% end %>
```

---

## 3. Permit params

อย่าลืม update strong params ใน `PostsController`:

```ruby
def post_params
  params.require(:post).permit(:title, :body, :published, :cover_image, tag_ids: [])
end
```

`:body` ตอนนี้มาจาก Action Text แล้ว แต่ยัง permit เหมือนเดิม ส่วน `:cover_image` เพิ่มเข้าไปใหม่

---

## Checkpoints

### Checkpoint 1 (Green)

> How many commands did it take? What did `rails action_text:install` create?

- **2 commands** (`install` + `migrate`) สำหรับแต่ละ feature
- สร้าง `action_text_rich_texts` table, Trix editor JS, และ Active Storage migration (ถ้ายังไม่มี)

### Checkpoint 2 (Yellow)

> Active Storage สร้าง tables อะไรบ้าง?

- **active_storage_blobs** — เก็บ metadata ของไฟล์ (filename, content type, size, checksum)
- **active_storage_attachments** — เชื่อม blob กับ model ที่ attach ไว้ มันคือ **join table** อีกตัวหนึ่ง!

สังเกตมั้ย? pattern เดียวกับ `post_tags` ที่เราทำใน step ก่อน — Active Storage ใช้ polymorphic join table เชื่อม blob กับ model ใดก็ได้

### Checkpoint 3 (Red)

> ใน React/Next ต้องทำอะไรบ้างถึงจะได้ rich text editor + file upload?

ลองนึกดู:

- **Rich text editor**: ต้องเลือก library (Tiptap, Slate, Draft.js, Quill), install npm packages, configure toolbar, handle serialization/deserialization, จัดการ HTML sanitization
- **File upload**: ต้อง setup multer หรือ formidable บน server, เลือก storage (S3, GCS, local), configure presigned URLs, handle multipart uploads
- **S3 setup**: สร้าง bucket, IAM policy, CORS config, environment variables
- **Image processing**: install sharp หรือ imagemagick, เขียน resize logic
- **Frontend**: สร้าง upload component, progress bar, drag & drop, preview

ทั้งหมดนี้ Rails ให้ฟรีด้วย **2 install commands**

---

## Self-check

- [ ] Post form แสดง rich text editor (Trix)
- [ ] สามารถ bold, italic, สร้าง list ใน body ได้
- [ ] สามารถ upload cover image ได้
- [ ] Cover image แสดงใน show page
- [ ] ทุกอย่างทำงานกับ Devise authentication + authorization ที่มีอยู่แล้ว

## Next Up

Step ต่อไป: **08-team-survival** — เราจะเรียนรู้การทำงานเป็นทีมกับ Git, conflict resolution, และ workflow ที่ใช้จริงในงาน
