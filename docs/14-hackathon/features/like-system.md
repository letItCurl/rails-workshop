---
feature: Like System
difficulty: "\U0001F7E2 Easy"
teaches: Polymorphic associations, counter
---

# Like System

## Business Need

> Users want to like posts.

A user can like a post. A user cannot like the same post twice. The like count is displayed on the post.

---

## ERD

```
┌──────────┐       ┌──────────────┐       ┌──────────┐
│  users   │       │    likes     │       │  posts   │
├──────────┤       ├──────────────┤       ├──────────┤
│ id       │──┐    │ id           │   ┌───│ id       │
│ email    │  └───>│ user_id      │   │   │ title    │
│ ...      │       │ likeable_id  │<──┘   │ body     │
│          │       │ likeable_type│       │ ...      │
└──────────┘       └──────────────┘       └──────────┘
```

The `likes` table uses **polymorphic associations** — `likeable_type` stores the class name (e.g., `"Post"`), `likeable_id` stores the record ID. This means you could extend likes to comments later without changing the schema.

---

## Steps

### 1. Generate the model

```bash
rails g model Like user:references likeable:references{polymorphic}
rails db:migrate
```

### 2. Wire up associations

**`app/models/like.rb`**
```ruby
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type] }
end
```

**`app/models/post.rb`** — add:
```ruby
has_many :likes, as: :likeable, dependent: :destroy
```

**`app/models/user.rb`** — add:
```ruby
has_many :likes, dependent: :destroy
```

### 3. Create the controller

```bash
rails g controller Likes create destroy --skip-routes
```

**`config/routes.rb`** — add inside resources :posts:
```ruby
resources :posts do
  resource :like, only: [:create, :destroy]
  resources :comments
end
```

**`app/controllers/likes_controller.rb`**
```ruby
class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    @post.likes.create(user: current_user)
    redirect_to @post
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.likes.where(user: current_user).destroy_all
    redirect_to @post
  end
end
```

### 4. Add like/unlike button to post show page

**`app/views/posts/show.html.erb`** — add:
```erb
<div class="flex items-center gap-2 mt-4">
  <% if current_user && @post.likes.exists?(user: current_user) %>
    <%= button_to "Unlike", post_like_path(@post), method: :delete,
        class: "text-red-500 hover:text-red-700" %>
  <% else %>
    <%= button_to "Like", post_like_path(@post), method: :post,
        class: "text-gray-500 hover:text-red-500" %>
  <% end %>
  <span><%= @post.likes.count %> likes</span>
</div>
```

---

## Test

**`test/models/like_test.rb`**
```ruby
require "test_helper"

class LikeTest < ActiveSupport::TestCase
  test "user can like a post" do
    user = users(:one)
    post = posts(:one)
    like = Like.create!(user: user, likeable: post)
    assert_includes post.likes, like
  end

  test "user cannot like the same post twice" do
    user = users(:one)
    post = posts(:one)
    Like.create!(user: user, likeable: post)
    duplicate = Like.new(user: user, likeable: post)
    assert_not duplicate.valid?
  end

  test "like count increments" do
    post = posts(:one)
    assert_difference "post.likes.count", 1 do
      Like.create!(user: users(:one), likeable: post)
    end
  end
end
```

---

## Hints (use only when stuck)

1. **Hint 1** — Did you run `rails db:migrate`?
2. **Hint 2** — The polymorphic columns are `likeable_id` and `likeable_type`. The `as: :likeable` on the Post model must match.
3. **Hint 3** — The uniqueness validation needs `scope:` with both `likeable_id` AND `likeable_type` to prevent duplicate likes across different likeable types.
