---
branch: 08-team-survival
title: "Team Survival — อยู่รอดในทีม"
lang: th
pair: guide-en.md
day: 1
time: "15:20–15:50"
duration: 30min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 07-rich-text-images
next: 09-erd-exercise
rails_guide: https://guides.rubyonrails.org/active_record_migrations.html
aha_moment: "Rails errors บอกคุณตรงๆ ว่าอะไรขาด — อ่านมัน"
business_rule: "ห้ามแก้ migration ของคนอื่น สร้างใหม่เสมอ"
---

# Team Survival — อยู่รอดในทีม

## คำถามจากธุรกิจ

คุณทำงานในทีม คนอื่นเปลี่ยน schema แล้ว pull มา error — ทำยังไง?

นี่คือสถานการณ์จริงที่เกิดขึ้นทุกวัน ไม่ว่าจะทีมเล็กหรือทีมใหญ่ ถ้าคุณรู้วิธีรับมือ คุณจะไม่กลัว migration อีกต่อไป

---

## 1. ดูสถานะปัจจุบัน

ก่อนทำอะไร ดูก่อนว่าตอนนี้ database อยู่ตรงไหน:

```bash
rails db:migrate:status
```

คุณจะเห็นรายการ migration ทั้งหมด พร้อมสถานะ **UP** (ทำแล้ว) หรือ **DOWN** (ยังไม่ได้ทำ):

```
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20260319010000  Create users
   up     20260319020000  Create posts
   up     20260319030000  Create comments
```

ถ้าเห็น **DOWN** อยู่ แสดงว่ามี migration ที่ยังไม่ได้ run — สั่ง `rails db:migrate` ได้เลย

---

## 2. สร้าง migration ฝึกมือ

ลองสร้าง migration เพิ่ม column ใหม่:

```bash
rails g migration AddViewCountToPosts view_count:integer
```

ดูไฟล์ที่ได้ใน `db/migrate/` — Rails สร้างให้อัตโนมัติ จากนั้น run:

```bash
rails db:migrate
```

เช็คว่า column เพิ่มแล้ว:

```bash
rails db:migrate:status
```

migration ใหม่ควรเป็น **UP**

---

## 3. อุ๊ปส์ ผิด column! Rollback

สมมติว่าเราไม่ต้องการ `view_count` แล้ว — ย้อนกลับ:

```bash
rails db:rollback
```

กลับไปดู status จะเห็นว่า migration ล่าสุดกลายเป็น **DOWN** ลอง run อีกทีเพื่อดู:

```bash
rails db:migrate:status
```

column `view_count` หายไปจาก schema แล้ว

---

## 4. กฎเหล็ก: ห้ามแก้ migration เก่า

มีสองสถานการณ์:

### สถานการณ์ A: ยังไม่ได้ push (แก้ได้)

ถ้า migration นี้อยู่แค่ในเครื่องคุณ ยังไม่ได้ push ขึ้น git:

1. `rails db:rollback` — ย้อน migration กลับ
2. ลบไฟล์ migration ที่ผิดทิ้ง
3. สร้างใหม่ให้ถูกต้อง
4. `rails db:migrate` อีกครั้ง

### สถานการณ์ B: push ไปแล้ว (ห้ามแก้!)

ถ้า push ไปแล้ว เพื่อนร่วมทีมอาจ run migration นั้นไปแล้ว:

**ห้ามแก้ ห้ามลบ สร้างใหม่เสมอ**

```bash
rails g migration RemoveViewCountFromPosts
```

แล้วเขียนใน migration file:

```ruby
class RemoveViewCountFromPosts < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :view_count, :integer
  end
end
```

จากนั้น:

```bash
rails db:migrate
```

> **กฎทอง: ถ้า push ไปแล้ว ห้ามแก้ ห้ามลบ สร้างใหม่เสมอ**

---

## 5. schema.rb conflict — เรื่องจริงในทีม

เมื่อ 2 คนสร้าง migration พร้อมกัน แล้ว merge เข้ามา `db/schema.rb` จะ conflict

ทำไม? เพราะ `schema.rb` มี timestamp ที่บรรทัดแรก ทุกครั้งที่ run migration มันจะอัพเดท

**วิธีแก้:**

1. Accept version ไหนก็ได้ของ `schema.rb` (ไม่สำคัญ)
2. Run `rails db:migrate`
3. Rails จะ regenerate `schema.rb` ให้ถูกต้องเอง
4. Commit `schema.rb` ที่ regenerate แล้ว

```bash
git checkout --theirs db/schema.rb   # หรือ --ours ก็ได้
rails db:migrate
git add db/schema.rb
git commit -m "Resolve schema.rb conflict"
```

อย่าพยายามแก้ `schema.rb` ด้วยมือ — ปล่อยให้ Rails จัดการ

---

## Checkpoints

### Checkpoint 1 (Green)

`rails db:migrate:status` แสดงอะไร?

> แสดงรายการ migration ทั้งหมด พร้อมสถานะ UP/DOWN บอกว่า migration ไหน run แล้ว ไหนยังไม่ได้ run

### Checkpoint 2 (Yellow)

เมื่อไหร่ลบ migration ได้ เมื่อไหร่ต้องสร้างใหม่?

> ลบได้เมื่อยังไม่ได้ push ขึ้น git (อยู่แค่ในเครื่องตัวเอง) ต้องสร้างใหม่เมื่อ push ไปแล้ว เพราะคนอื่นอาจ run ไปแล้ว

### Checkpoint 3 (Red)

เพื่อนร่วมทีม push migration ที่ conflict กับของคุณ ทำยังไง?

> 1. Pull ลงมา
> 2. แก้ conflict ใน schema.rb (accept version ไหนก็ได้)
> 3. Run `rails db:migrate` — schema.rb จะ regenerate ให้ถูก
> 4. ถ้า migration ของคุณ error เพราะ column ซ้ำ ให้ rollback แล้วสร้าง migration ใหม่ที่ไม่ซ้ำ
> 5. Commit schema.rb ที่สะอาดแล้ว

---

## สรุป

| สถานการณ์ | วิธีแก้ |
|---|---|
| Migration ผิด ยังไม่ push | rollback + ลบ + สร้างใหม่ |
| Migration ผิด push แล้ว | สร้าง migration ใหม่เพื่อแก้ |
| schema.rb conflict | accept either + `rails db:migrate` |
| PendingMigrationError | `rails db:migrate` |

วงจร **rollback -> แก้ -> migrate** คือ workflow ปกติ ไม่ใช่ความผิดพลาด

---

## Self-check

- [ ] ฉัน run `rails db:migrate:status` ได้และอ่านผลลัพธ์เข้าใจ
- [ ] ฉันเคย rollback แล้ว migrate กลับสำเร็จ
- [ ] ฉันรู้ว่าเมื่อไหร่ลบ migration ได้ เมื่อไหร่ต้องสร้างใหม่
- [ ] ฉันรู้วิธีแก้ schema.rb conflict

## ต่อไป

Step ถัดไป: **09-erd-exercise** — เราจะมาวาด ERD ของ OddlyHonest กัน เพื่อเห็นภาพรวมของ data model ทั้งหมด
