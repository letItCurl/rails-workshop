---
feature: Bookmarks
difficulty: "\U0001F7E1 Medium"
teaches: "has_many :through, join tables"
---

# Bookmarks

## Business Need

> Users want to save posts for later.

A user can bookmark a post. A user can unbookmark a post. A user can see all their bookmarked posts on their profile.

---

## ERD

```
┌──────────┐       ┌──────────────┐       ┌──────────┐
│  users   │       │  bookmarks   │       │  posts   │
├──────────┤       ├──────────────┤       ├──────────┤
│ id       │──┐    │ id           │   ┌───│ id       │
│ email    │  └───>│ user_id      │   │   │ title    │
│ ...      │       │ post_id      │<──┘   │ body     │
│          │       │ created_at   │       │ ...      │
└──────────┘       └──────────────┘       └──────────┘
```

The `bookmarks` table is a **join table** between `users` and `posts`. We use `has_many :through` to access bookmarked posts directly from a user.

---

## Steps

### 1. Generate the model

```bash
rails g model Bookmark user:references post:references
rails db:migrate
```

### 2. Wire up associations

**`app/models/bookmark.rb`**
```ruby
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }
end
```

**`app/models/user.rb`** — add:
```ruby
has_many :bookmarks, dependent: :destroy
has_many :bookmarked_posts, through: :bookmarks, source: :post
```

**`app/models/post.rb`** — add:
```ruby
has_many :bookmarks, dependent: :destroy
has_many :bookmarked_by_users, through: :bookmarks, source: :user
```

### 3. Create the controller

```bash
rails g controller Bookmarks create destroy --skip-routes
```

**`config/routes.rb`** — add:
```ruby
resources :posts do
  resource :bookmark, only: [:create, :destroy]
  resources :comments
end

# Add a route for the bookmarks index
get "my/bookmarks", to: "bookmarks#index", as: :my_bookmarks
```

**`app/controllers/bookmarks_controller.rb`**
```ruby
class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = current_user.bookmarked_posts
  end

  def create
    @post = Post.find(params[:post_id])
    current_user.bookmarks.create(post: @post)
    redirect_to @post, notice: "Post bookmarked."
  end

  def destroy
    @post = Post.find(params[:post_id])
    current_user.bookmarks.where(post: @post).destroy_all
    redirect_to @post, notice: "Bookmark removed."
  end
end
```

### 4. Add bookmark/unbookmark button to post show page

**`app/views/posts/show.html.erb`** — add:
```erb
<div class="mt-4">
  <% if current_user %>
    <% if current_user.bookmarked_posts.include?(@post) %>
      <%= button_to "Remove Bookmark", post_bookmark_path(@post), method: :delete,
          class: "text-yellow-600 hover:text-yellow-800" %>
    <% else %>
      <%= button_to "Bookmark", post_bookmark_path(@post), method: :post,
          class: "text-gray-500 hover:text-yellow-600" %>
    <% end %>
  <% end %>
</div>
```

### 5. Create bookmarks index page

**`app/views/bookmarks/index.html.erb`**
```erb
<div class="max-w-4xl mx-auto py-8">
  <h1 class="text-2xl font-bold mb-6">My Bookmarked Posts</h1>

  <% if @posts.any? %>
    <% @posts.each do |post| %>
      <div class="border-b py-4">
        <%= link_to post.title, post, class: "text-xl text-blue-600 hover:underline" %>
        <p class="text-gray-500 text-sm">by <%= post.user.email %></p>
      </div>
    <% end %>
  <% else %>
    <p class="text-gray-500">No bookmarked posts yet.</p>
  <% end %>
</div>
```

### 6. Add link in navigation

Add a "My Bookmarks" link in the nav bar for signed-in users:
```erb
<%= link_to "My Bookmarks", my_bookmarks_path %>
```

---

## Test

**`test/models/bookmark_test.rb`**
```ruby
require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  test "user can bookmark a post" do
    user = users(:one)
    post = posts(:one)
    bookmark = Bookmark.create!(user: user, post: post)
    assert_includes user.bookmarked_posts, post
  end

  test "user can unbookmark a post" do
    user = users(:one)
    post = posts(:one)
    bookmark = Bookmark.create!(user: user, post: post)
    bookmark.destroy
    assert_not_includes user.bookmarked_posts.reload, post
  end

  test "bookmarked_posts returns correct posts" do
    user = users(:one)
    post1 = posts(:one)
    post2 = posts(:two)
    Bookmark.create!(user: user, post: post1)
    assert_includes user.bookmarked_posts, post1
    assert_not_includes user.bookmarked_posts, post2
  end
end
```

---

## Hints (use only when stuck)

1. **Hint 1** — `has_many :through` requires TWO `has_many` declarations: one for the join table (`has_many :bookmarks`) and one through it (`has_many :bookmarked_posts, through: :bookmarks`).
2. **Hint 2** — The `source: :post` option tells Rails which association on the Bookmark model to follow. Without it, Rails would look for `:bookmarked_post` on Bookmark and fail.
3. **Hint 3** — If `bookmarked_posts` returns nothing, check that the Bookmark record was actually saved. Run `Bookmark.count` in the console.
