---
branch: 04-publish-rules
title: "Publish Rules — แก้ไขไม่ได้เมื่อ publish แล้ว"
lang: th
pair: guide-en.md
day: 1
time: "11:45–12:15"
duration: 30min
difficulty: 🟡 Recipe + Why
prerequisite: 03-auth
next: 05-comments
rails_guide: https://guides.rubyonrails.org/active_record_validations.html
aha_moment: "Business rules อยู่ใน model — ถึง controller มี bug ข้อมูลก็ปลอดภัย"
business_rule: "โพสต์ที่ publish แล้วแก้ไขไม่ได้ — คุณพูดไปแล้ว คุณต้องรับผิดชอบ"
---

# 🔒 คุณพูดไปแล้ว — แก้ไม่ได้

OddlyHonest เป็นแพลตฟอร์มแชร์ความจริง ถ้าคุณ publish ไปแล้ว — มันเป็นของจริง แก้ไขไม่ได้ เหมือนพูดออกไปแล้วเอาคืนไม่ได้

ฟังดูเหมือนกฎ business ธรรมดา แต่คำถามคือ: **เราจะ enforce กฎนี้ที่ไหน?**

- ใน frontend? (ซ่อนปุ่ม edit) → bypass ได้ง่ายมาก
- ใน controller? (check ก่อน update) → ดีกว่า แต่ถ้ามีหลาย controller ที่ update post?
- **ใน model** → **ถูกต้อง** ไม่ว่าจะ update จากไหน กฎนี้ protect ข้อมูลเสมอ

**นี่คือหลักการ: Business rules อยู่ใน model**

---

## เพิ่ม published field

```bash
rails g migration AddPublishedToPosts published:boolean
```

เปิด migration file ที่สร้างขึ้นมา — เพิ่ม default value:

```ruby
add_column :posts, :published, :boolean, default: false
```

```bash
rails db:migrate
```

เปิด `db/schema.rb` — เห็น `published` column ใน posts table มั้ย?

---

## เขียน test ก่อน

**ก่อนเขียน code — เขียน test ก่อน** ถ้า test pass ก่อนที่เราเขียน validation แสดงว่า test เราผิด

สร้างไฟล์ test:

```bash
rails g test_unit:model post
```

เปิด `test/models/post_test.rb` แล้วเขียน:

```ruby
require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "draft post can be updated" do
    post = Post.create!(title: "Draft", body: "content", published: false)
    post.update!(title: "Updated Draft")
    assert_equal "Updated Draft", post.title
  end

  test "published post cannot be updated" do
    post = Post.create!(title: "Truth", body: "content", published: true)
    post.title = "Edited Truth"
    assert_not post.valid?
    assert_includes post.errors[:base], "Published posts cannot be edited"
  end
end
```

Run it:

```bash
rails test test/models/post_test.rb
```

**ต้อง fail** — เพราะเรายังไม่ได้เขียน validation นั่นคือสิ่งที่ถูกต้อง ถ้า test pass ตอนนี้แสดงว่า test ไม่ได้ test อะไรเลย

---

## เขียน validation ใน model

เปิด `app/models/post.rb` เพิ่ม:

```ruby
validate :cannot_edit_once_published

private

def cannot_edit_once_published
  if published? && changed? && !published_changed?
    errors.add(:base, "Published posts cannot be edited")
  end
end
```

**อ่านโค้ดนี้:** ถ้าโพสต์ถูก publish แล้ว (`published?`) และมีการเปลี่ยนแปลง (`changed?`) แต่ไม่ใช่การเปลี่ยน published field เอง (`!published_changed?`) → block

นั่นหมายความว่า: คุณ publish ได้ (เปลี่ยน `published` จาก false เป็น true) แต่หลังจาก publish แล้ว แก้อะไรไม่ได้

Run test อีกครั้ง:

```bash
rails test test/models/post_test.rb
```

**ต้อง pass** ทั้งสอง test

---

## เพิ่ม publish button ใน UI

เปิด `app/views/posts/show.html.erb` เพิ่มปุ่ม publish:

```erb
<% unless @post.published? %>
  <%= button_to "Publish", post_path(@post), method: :patch,
      params: { post: { published: true } },
      class: "bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700" %>
<% end %>

<% if @post.published? %>
  <span class="inline-block bg-green-100 text-green-800 text-sm px-3 py-1 rounded-full">Published</span>
<% end %>
```

อย่าลืมเพิ่ม `:published` ใน `post_params`:

```ruby
def post_params
  params.expect(post: [ :title, :body, :published ])
end
```

---

## 🧪 ลองตอบดู

1. **ทำไม validation อยู่ใน model ไม่ใช่ controller?**
2. **ถ้า test pass ก่อนที่เขียน validation — หมายความว่าอะไร?**
3. **`changed?` กับ `published_changed?` ต่างกันยังไง?**

**คุยกับคนข้างๆ:** "CI อาจ pass ทุก test แต่ถ้าคุณไม่ test business rule นี้ แอปก็ยังรั่วอยู่" — หมายความว่ายังไง?

---

## 🧪 เขียน Test เพิ่มเอง

**🔴 Challenge — ไม่มีตัวอย่าง:**

> เขียน test ที่พิสูจน์ว่า: draft post สามารถถูก publish ได้ (เปลี่ยน published จาก false เป็น true)

ถ้าติดเกิน 5 นาที:
- 💡 Hint 1: สร้าง post ที่ `published: false`
- 💡 Hint 2: ใช้ `post.update!(published: true)`
- 💡 Hint 3: `assert post.published?`

---

## ✅ ก่อนไปต่อ

- [ ] `published` column อยู่ใน posts table
- [ ] test เขียนก่อน validation — fail ก่อนแล้ว pass
- [ ] published post แก้ไขไม่ได้ (validation block)
- [ ] draft post publish ได้
- [ ] เข้าใจว่าทำไม business rules อยู่ใน model

---

## ➡️ ต่อไป: Branch `05-comments`

Users อยากแสดงความเห็นเกี่ยวกับโพสต์ — relationship คืออะไร? และเหมือนโพสต์ comment ก็แก้ไขไม่ได้
