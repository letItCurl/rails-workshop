---
branch: 05-comments-authorization
title: "Authorization — คุณพลาด Business Rule"
lang: th
pair: guide-en.md
day: 1
time: "13:40–13:50"
duration: 10min
difficulty: 🟡 Recipe + Why
prerequisite: 05-comments
next: 06-tags
rails_guide: https://guides.rubyonrails.org/action_controller_overview.html
aha_moment: "Test pass ≠ ถูกต้อง — ถ้าคุณไม่ test business rule ที่ลืม มันก็ไม่มีทาง fail"
business_rule: "เฉพาะเจ้าของเท่านั้นที่ลบ comment/post ของตัวเองได้"
---

# ⚠️ คุณพลาดอะไรไป

หยุดแป๊บ ย้อนกลับไปดูโค้ดที่เพิ่งเขียน

Test pass ทั้งหมด Comment สร้างได้ ลบได้ แก้ไขไม่ได้ ดูเหมือนครบ

**แต่...** login เป็น User A แล้วลองลบ comment ของ User B ดู

ได้มั้ย?

**ได้** และนั่นคือ bug

เราเขียน test สำหรับ "comment ต้องมี post" กับ "comment ต้องมี user" — แต่เราไม่เคย test ว่า **"เฉพาะเจ้าของเท่านั้นที่ลบได้"**

CI ผ่านทุก test แต่แอปยังมีช่องโหว่ นี่คือสิ่งที่หมายความว่า "test coverage ไม่ได้บอกว่าแอปถูกต้อง"

---

## เขียน Test ก่อน

เปิด `test/models/comment_test.rb` เพิ่ม... เดี๋ยว จริงๆ นี่ไม่ใช่ model test นี่คือ controller behavior

สร้าง test ใหม่:

```bash
mkdir -p test/controllers
```

เปิด `test/controllers/comments_controller_test.rb`:

```ruby
require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = User.create!(email: "owner@test.com", password: "password")
    @other = User.create!(email: "other@test.com", password: "password")
    @post = Post.create!(title: "Test", body: "content", user: @owner)
    @comment = Comment.create!(body: "My truth", post: @post, user: @owner)
  end

  test "owner can delete their own comment" do
    sign_in @owner
    assert_difference("Comment.count", -1) do
      delete comment_path(@comment)
    end
  end

  test "other user cannot delete someone else's comment" do
    sign_in @other
    delete comment_path(@comment)
    assert_response :redirect
    assert Comment.exists?(@comment.id), "Comment should still exist"
  end
end
```

Run:

```bash
rails test test/controllers/comments_controller_test.rb
```

**test ที่ 2 จะ fail** — เพราะตอนนี้ใครก็ลบได้

---

## Fix: เฉพาะเจ้าของลบได้

เปิด `app/controllers/comments_controller.rb` แก้ `destroy`:

```ruby
def destroy
  if @comment.user == current_user
    post = @comment.post
    @comment.destroy!
    redirect_to post_path(post), notice: "Comment was successfully destroyed.", status: :see_other
  else
    redirect_to post_path(@comment.post), alert: "You can only delete your own comments."
  end
end
```

ทำเหมือนกันกับ posts — เปิด `app/controllers/posts_controller.rb` แก้ `destroy` กับ `edit` กับ `update`:

```ruby
before_action :authorize_owner!, only: %i[ edit update destroy ]

# ... existing actions ...

private

def authorize_owner!
  unless @post.user == current_user
    redirect_to posts_path, alert: "You can only edit/delete your own posts."
  end
end
```

Run tests อีกครั้ง:

```bash
rails test
```

**ทุก test ต้อง pass**

---

## 🧪 ลองตอบดู

1. **ทำไม test ก่อนหน้านี้ไม่จับ bug นี้ได้?**
2. **test coverage 100% แปลว่าแอปไม่มี bug จริงมั้ย?**
3. **Authorization กับ Authentication ต่างกันยังไง?**

**คุยกับคนข้างๆ:** "ถ้าคุณสร้าง SaaS แบบ multi-tenant แล้ว scope query ไม่ถูก — CI ผ่านหมดแต่ data ลูกค้ารั่ว" ฟังคุ้นมั้ย?

---

## ✅ ก่อนไปต่อ

- [ ] เฉพาะเจ้าของ comment เท่านั้นที่ลบได้
- [ ] เฉพาะเจ้าของ post เท่านั้นที่ edit/delete ได้
- [ ] Test พิสูจน์ว่า user อื่นลบ comment คนอื่นไม่ได้
- [ ] เข้าใจว่า test pass ≠ ไม่มี bug

---

## ➡️ ต่อไป: Branch `06-tags`

โพสต์ต้องมีหมวดหมู่ — นี่คือ "the one kick"
