---
branch: 09-erd-exercise
title: "ERD Exercise — Model ปัญหาได้ทุกอย่าง"
lang: th
pair: guide-en.md
day: 1
time: "15:50–16:30"
duration: 40min
difficulty: "\U0001F534 Challenge"
prerequisite: 08-team-survival
next: 10-turbo-frames
rails_guide:
  - https://guides.rubyonrails.org/active_record_basics.html
  - https://guides.rubyonrails.org/association_basics.html
aha_moment: "ให้ business problem มา ฉัน sketch ERD ได้ — นี่คือ skill ที่ AI แทนไม่ได้"
business_rule: "ไม่มี business rule ใหม่ — step นี้คือพิสูจน์ว่าคุณ model ได้"
---

# ERD Exercise — Model ปัญหาได้ทุกอย่าง

## ลืมโค้ดไปก่อน

หยิบปากกากับกระดาษ

ตลอดทั้งวันคุณเขียนโค้ด — สร้าง models, migrations, associations, validations, tests ทุกอย่าง แต่ทักษะที่สำคัญที่สุดไม่ใช่การพิมพ์โค้ด มันคือ **การเข้าใจปัญหาแล้ว model ออกมาเป็น database**

ถ้าคุณเข้าใจ business → database → code จริง คุณ model ปัญหาอะไรก็ได้

---

## Step 1: ดู ERD ของ OddlyHonest ที่เราสร้างมาทั้งวัน

Generate ERD ของแอปปัจจุบัน:

```bash
bundle exec rails-erd
```

(หรือ `rails erd` ถ้าติดตั้งเป็น binstub)

เปิดไฟล์ ERD ที่ได้ (ปกติจะเป็น `erd.pdf` หรือ `erd.png`) แล้วดู diagram

**ถามตัวเอง:** diagram นี้ตรงกับสิ่งที่คุณสร้างมามั้ย? เห็น relationships ทั้งหมดมั้ย? Post → Comment, Post ↔ Tag ผ่าน PostTag, User → Post?

---

## Step 2: 5 ปัญหา 5 ERDs

สำหรับแต่ละปัญหา:
- อ่านโจทย์ business
- วาด ERD บนกระดาษ เป็นกลุ่ม (5 นาที)
- อภิปรายคำตอบ

---

### Problem 1: ร้านอาหาร Delivery (Food Delivery)

**Business:** ร้านอาหารมีเมนูหลายอย่าง ลูกค้าสั่งอาหาร แต่ละออเดอร์มีรายการอาหารหลายอย่าง แต่ละรายการอ้างอิงไปที่เมนู ลูกค้ามีที่อยู่สำหรับ delivery

**Entities ที่ต้องมี:**
- Restaurant
- MenuItem
- Customer
- Order
- OrderItem

**Key question:** "OrderItem เป็น join table ระหว่างอะไรกับอะไร?"

> OrderItem เชื่อม Order กับ MenuItem — เหมือน PostTag ที่เชื่อม Post กับ Tag แต่ OrderItem มี quantity, price ด้วย

---

### Problem 2: จองโรงแรม (Hotel Booking)

**Business:** โรงแรมมีห้องหลายห้อง แต่ละห้องมีประเภทและราคา แขกสร้างการจองสำหรับห้องเฉพาะ + วันที่เข้า/ออก

**Entities ที่ต้องมี:**
- Hotel
- Room
- Guest
- Booking

**Key question:** "Booking belongs_to อะไรบ้าง?"

> Booking belongs_to :guest และ belongs_to :room — มันเป็น join table ระหว่าง Guest กับ Room แต่มี check_in, check_out dates

---

### Problem 3: ระบบโรงเรียน (School System)

**Business:** นักเรียนลงทะเบียนเรียนวิชา วิชาสอนโดยอาจารย์ การลงทะเบียนเป็น join table ที่มีเกรด

**Entities ที่ต้องมี:**
- Student
- Course
- Teacher
- Enrollment

**Key question:** "Enrollment has_many :through — เหมือน PostTag มั้ย?"

> ใช่เลย! Student has_many :courses, through: :enrollments เหมือน Post has_many :tags, through: :post_tags แต่ Enrollment มี grade เพิ่มมา

---

### Problem 4: ร้านค้าออนไลน์ (E-commerce)

**Business:** สินค้าอยู่ในหมวดหมู่ ผู้ใช้เพิ่มสินค้าลงตะกร้าผ่าน CartItem ผู้ใช้สั่งซื้อผ่าน OrderItem

**Entities ที่ต้องมี:**
- Product
- Category
- User
- Cart
- CartItem
- Order
- OrderItem

**Key question:** "CartItem กับ OrderItem ต่างกันยังไง? ทำไมแยก?"

> CartItem คือ "ของที่อยากได้" — ลบได้ แก้ได้ ยังไม่จ่ายเงิน OrderItem คือ "ของที่ซื้อแล้ว" — เป็น historical record ลบไม่ได้ ราคา ณ ตอนสั่งซื้อต้อง freeze ไว้

---

### Problem 5: ระบบ Follow (Social Media Follow System)

**Business:** User follow User ได้ Follow เป็น self-referential join table ที่มี follower_id กับ followed_id

**Entities ที่ต้องมี:**
- User
- Follow

**Key question:** "Follow table มี user_id สองอัน — ทำยังไง?"

> Follow belongs_to :follower, class_name: "User" และ belongs_to :followed, class_name: "User" — table เดียว foreign key สองอัน ชี้ไปที่ users table เดียวกัน

---

## Step 3: เลือก 1 ปัญหา สร้างจริง

เลือกปัญหาที่ชอบที่สุด 1 ข้อ แล้วสร้าง models จริง:

```bash
# ตัวอย่าง: ถ้าเลือก Problem 1 - Food Delivery
rails g model Restaurant name:string
rails g model MenuItem name:string price:decimal restaurant:references
rails g model Customer name:string address:text
rails g model Order customer:references restaurant:references status:string
rails g model OrderItem order:references menu_item:references quantity:integer price:decimal

rails db:migrate
```

แล้ว generate ERD อีกรอบ:

```bash
bundle exec rails-erd
```

ดู diagram — ตรงกับที่วาดบนกระดาษมั้ย?

---

## Reflection: ทักษะที่ AI แทนไม่ได้

ในยุค AI ทักษะที่ AI แทนไม่ได้คือ **เข้าใจปัญหา → model database**

AI สร้างโค้ดได้ แต่ AI ไม่รู้ว่า business ของคุณต้องการอะไร ไม่รู้ว่า CartItem กับ OrderItem ต้องแยก ไม่รู้ว่า Follow ต้องเป็น self-referential

**นั่นคือสิ่งที่คุณเพิ่งทำ**

---

## Day 1 Wrap-up

คุณเริ่มจาก `rails new` สร้างแอปทั้งหมด:

- CRUD สำหรับ Posts
- Comments ที่ belongs_to Post
- Authentication ด้วย Devise
- Business rules (ห้ามลบ post ที่มี comments, ห้ามแก้ post คนอื่น)
- Tags ผ่าน many-to-many (PostTag)
- Rich Text ด้วย Action Text
- Image uploads ด้วย Active Storage
- Tests ทั้งหมด
- Team collaboration workflow
- ERD modeling สำหรับ 5 business problems

**ทั้งหมดในวันเดียว**

---

## Self-check

- [ ] Generate ERD ของ OddlyHonest ได้
- [ ] วาด ERD สำหรับ 5 ปัญหาบนกระดาษได้
- [ ] อธิบายได้ว่า join table คืออะไร ใช้เมื่อไหร่
- [ ] อธิบาย self-referential association ได้
- [ ] เลือก 1 ปัญหาแล้วสร้าง models จริงได้
- [ ] ERD ที่ generate ตรงกับที่วาดบนกระดาษ

## Day 2 Teaser

พรุ่งนี้เราจะเอาแอปที่สร้างมา ทำให้ **interactive** ด้วย Turbo Frames, Stimulus, และ Hotwire — ทำให้หน้าเว็บ update โดยไม่ต้อง reload ทั้งหน้า ถ้าวันนี้คือ "เข้าใจ data" พรุ่งนี้คือ "เข้าใจ interaction"
