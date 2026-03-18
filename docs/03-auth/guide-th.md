---
branch: 03-auth
title: "Auth — ใครโพสต์ล่ะ?"
lang: th
pair: guide-en.md
day: 1
time: "11:15–11:45"
duration: 30min
difficulty: 🟢 Recipe
prerequisite: 02-posts
next: 04-publish-rules
rails_guide: https://guides.rubyonrails.org/security.html
aha_moment: "Auth ใน 3 คำสั่ง — ใช้เวลาเท่าไหร่ในโปรเจคที่แล้ว?"
business_rule: "ต้อง login ถึงจะสร้างโพสต์ได้ แต่อ่านได้ทุกคน"
---

# 🔐 ใครโพสต์ล่ะ?

ตอนนี้แอปเรามีปัญหา — ใครก็โพสต์ได้ ใครก็แก้ไขได้ ใครก็ลบได้ ไม่รู้ว่าโพสต์ไหนเป็นของใคร

ลองคิดแบบ business: "OddlyHonest เป็นแพลตฟอร์มที่ทุกคนอ่านได้ แต่ต้อง login ถึงจะโพสต์ได้"

**คำถาม:** ใน React/Next คุณสร้าง auth system ใช้เวลาเท่าไหร่? สัปดาห์? สองสัปดาห์?

---

## ติดตั้ง Devise

Devise คือ gem สำหรับ authentication ที่ Rails community ใช้กันมากที่สุด ไม่ต้องเขียน auth เอง:

```bash
bundle add devise
```

```bash
rails g devise:install
```

**สังเกต:** Devise บอกให้คุณทำอะไรบ้างใน terminal — อ่านแล้วทำตาม

---

## สร้าง User Model

```bash
rails g devise User
```

**สังเกต:** ดูไฟล์ที่สร้าง:
- `app/models/user.rb` — User model พร้อม Devise modules
- `db/migrate/..._devise_create_users.rb` — migration สร้าง users table
- `config/routes.rb` — เพิ่ม `devise_for :users` อัตโนมัติ

```bash
rails db:migrate
```

เปิด `db/schema.rb` — เห็น `users` table มั้ย? มี email, encrypted_password, ทุกอย่างที่ auth ต้องการ

---

## เชื่อม User กับ Post

Post ต้องรู้ว่าใครเป็นเจ้าของ — ต้องมี `user_id`:

```bash
rails g migration AddUserToPosts user:references
rails db:migrate
```

เปิด `app/models/post.rb` เพิ่ม:

```ruby
belongs_to :user
```

เปิด `app/models/user.rb` เพิ่ม:

```ruby
has_many :posts, dependent: :destroy
```

**คิดดู:** `belongs_to` หมายความว่า Post ไม่สามารถมีอยู่ได้ถ้าไม่มี User — relationship อยู่ใน database (foreign key)

---

## ล็อคการสร้างโพสต์

เปิด `app/controllers/posts_controller.rb` เพิ่มที่บรรทัดแรกใน class:

```ruby
before_action :authenticate_user!, except: [:index, :show]
```

แก้ `create` action ให้สร้างโพสต์ผ่าน current_user:

```ruby
def create
  @post = current_user.posts.build(post_params)
  # ... rest stays the same
end
```

---

## ทดสอบ

1. เปิด browser — ไป `/posts` → **เห็นโพสต์ได้** (ไม่ต้อง login)
2. กด "New post" → **redirect ไปหน้า login** (ต้อง login ก่อน)
3. สมัคร account → login → สร้างโพสต์ → **ได้!**

---

## 🧪 ลองตอบดู

1. **`belongs_to :user` ใน Post model หมายความว่าอะไร?**
2. **ถ้าลบ User — โพสต์ของ User นั้นจะเป็นยังไง?** (hint: ดู `dependent: :destroy`)
3. **`before_action :authenticate_user!, except: [:index, :show]` ทำอะไร?**

**คุยกับคนข้างๆ:** 3 คำสั่ง (bundle add, devise:install, devise User) ให้ auth ทั้ง system — signup, login, logout, password reset ใช้เวลาเท่าไหร่ในโปรเจคที่แล้ว?

---

## ✅ ก่อนไปต่อ

- [ ] Devise ติดตั้งแล้ว User model มี
- [ ] Post belongs_to :user
- [ ] อ่านโพสต์ได้โดยไม่ต้อง login
- [ ] สร้างโพสต์ต้อง login
- [ ] เข้าใจ `belongs_to` กับ `has_many`

---

## ➡️ ต่อไป: Branch `04-publish-rules`

ตอนนี้มี auth แล้ว แต่ถ้าโพสต์ถูก publish ไปแล้ว — ควรแก้ไขได้มั้ย? "คุณพูดไปแล้ว คุณต้องรับผิดชอบ"
