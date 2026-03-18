---
branch: 05-comments
title: "Comments — ความเห็นที่แก้ไม่ได้"
lang: th
pair: guide-en.md
day: 1
time: "13:15–13:50"
duration: 35min
difficulty: 🟡 Recipe + Why
prerequisite: 04-publish-rules
next: 06-tags
rails_guide: https://guides.rubyonrails.org/association_basics.html
aha_moment: "Scaffold ให้ CRUD ครบ แล้วเราเลือกเอาออก — นั่นคือ business decision"
business_rule: "Login ถึงจะ comment ได้ แก้ไข comment ไม่ได้เด็ดขาด"
---

# 💬 Users อยากแสดงความเห็น — Relationship คืออะไร?

โพสต์อยู่ได้เดี่ยวๆ แต่ comment อยู่เดี่ยวๆ ไม่ได้ — มันต้อง *อยู่ใน* โพสต์ ต้อง *เป็นของ* คนที่เขียน

ลองคิดก่อนเขียนโค้ด: comment เชื่อมกับอะไรบ้าง?

- Comment → Post (comment อยู่ในโพสต์ไหน?)
- Comment → User (ใครเขียน?)

ใน database หมายความว่า comments table ต้องมี `post_id` กับ `user_id` — นั่นคือ `belongs_to`

**คำถาม:** `belongs_to` หมายความว่าอะไรในแง่ database? (hint: foreign key)

---

## Scaffold Comment

```bash
rails g scaffold Comment body:text post:references user:references
```

**สังเกต:** ดูไฟล์ที่สร้าง:
- `app/models/comment.rb` — มี `belongs_to :post` กับ `belongs_to :user` ให้แล้ว!
- `db/migrate/..._create_comments.rb` — มี foreign keys
- `app/controllers/comments_controller.rb` — CRUD ครบ
- `app/views/comments/` — views ทั้งหมด

```bash
rails db:migrate
```

เปิด `db/schema.rb` — เห็น comments table มั้ย? มี `post_id` กับ `user_id`

---

## เชื่อม Model

scaffold สร้าง `belongs_to` ใน Comment ให้แล้ว แต่ต้องบอก Post กับ User ว่ามี comments:

เปิด `app/models/post.rb` เพิ่ม:

```ruby
has_many :comments, dependent: :destroy
```

เปิด `app/models/user.rb` เพิ่ม:

```ruby
has_many :comments, dependent: :destroy
```

**คิดดู:** `dependent: :destroy` หมายความว่า ถ้าลบโพสต์ → comments ทั้งหมดของโพสต์นั้นถูกลบด้วย ถ้าลบ user → comments ทั้งหมดของ user นั้นถูกลบด้วย

---

## ลบ Edit/Update ออก — Business Decision

นี่คือจุดสำคัญ: scaffold ให้ CRUD ครบ แต่ OddlyHonest มีกฎว่า **comment แก้ไขไม่ได้** คุณพูดไปแล้ว จบ

เปิด `config/routes.rb` เปลี่ยน:

```ruby
resources :comments
```

เป็น:

```ruby
resources :comments, except: [:edit, :update]
```

เปิด `app/controllers/comments_controller.rb` — **ลบ** `edit` action กับ `update` action ออกทั้งหมด

ลบ `app/views/comments/edit.html.erb` ด้วย

**นี่คือ aha moment:** Rails ให้ทุกอย่าง แล้วคุณเลือกเอาออก ไม่ใช่เลือกเพิ่มเข้า นั่นคือ business decision — ไม่ใช่ technical decision

---

## ล็อค Comment ให้ต้อง Login

เปิด `app/controllers/comments_controller.rb` เพิ่ม:

```ruby
before_action :authenticate_user!, except: [:index, :show]
```

แก้ `create` action:

```ruby
def create
  @comment = current_user.comments.build(comment_params)
  # ... rest stays the same
end
```

---

## แสดง Comments ในหน้า Post

เปิด `app/views/posts/show.html.erb` เพิ่มส่วน comments:

```erb
<h2 class="font-bold text-2xl mt-8 mb-4">Comments</h2>

<% @post.comments.each do |comment| %>
  <div class="border-b border-gray-200 py-3">
    <p class="text-gray-800"><%= comment.body %></p>
    <p class="text-sm text-gray-500"><%= comment.user&.email %> — <%= time_ago_in_words(comment.created_at) %> ago</p>
  </div>
<% end %>

<% if user_signed_in? %>
  <h3 class="font-medium text-lg mt-6 mb-2">Add a comment</h3>
  <%= form_with(model: Comment.new, url: comments_path) do |f| %>
    <%= f.hidden_field :post_id, value: @post.id %>
    <div class="mb-3">
      <%= f.text_area :body, rows: 3, placeholder: "Share your truth...",
          class: "w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" %>
    </div>
    <%= f.submit "Comment", class: "bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 cursor-pointer" %>
  <% end %>
<% end %>
```

แก้ redirect ใน comments controller ให้กลับไปหน้า post:

```ruby
def create
  @comment = current_user.comments.build(comment_params)
  if @comment.save
    redirect_to post_path(@comment.post), notice: "Comment was successfully created."
  else
    redirect_to post_path(@comment.post), alert: "Comment could not be created."
  end
end
```

---

## 🧪 ลองตอบดู

1. **`belongs_to :post` ใน Comment หมายความว่าอะไรใน database?** (hint: column ไหน?)
2. **ทำไมเราลบ edit/update ออกจาก routes แทนที่จะแค่ซ่อนปุ่ม?**
3. **`dependent: :destroy` ทำอะไร? ถ้าไม่ใส่จะเกิดอะไร?**

---

## 🧪 เขียน Test เอง

**🔴 Challenge:**

> เขียน test ที่พิสูจน์ว่า: comment ไม่สามารถสร้างได้ถ้าไม่มี post (post_id = nil)

ถ้าติดเกิน 5 นาที:
- 💡 Hint 1: ใช้ `test/models/comment_test.rb`
- 💡 Hint 2: `Comment.new(body: "test", user: user, post: nil)`
- 💡 Hint 3: `assert_not comment.valid?`

---

## ✅ ก่อนไปต่อ

- [ ] Comment scaffold สร้างแล้ว มี belongs_to ทั้งสอง
- [ ] Post has_many :comments, User has_many :comments
- [ ] Edit/update routes ถูกลบ — comment แก้ไม่ได้
- [ ] ต้อง login ถึงจะ comment ได้
- [ ] Comments แสดงในหน้า post
- [ ] เข้าใจ `belongs_to` กับ `dependent: :destroy`

---

## ➡️ ต่อไป: Branch `06-tags`

โพสต์ต้องมีหมวดหมู่ แต่โพสต์หนึ่งมีหลาย tags และ tag หนึ่งก็อยู่ในหลายโพสต์ — จะทำยังไง? นี่คือ "the one kick"
