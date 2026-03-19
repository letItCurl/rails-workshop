---
feature: Real-time Comment Notifications
difficulty: "\U0001F7E1 Medium"
teaches: Callbacks, Turbo Streams broadcast, polymorphic associations
---

# Real-time Comment Notifications

## Business Need

> Post author gets notified when someone comments on their post.

When a user comments on a post, the post author receives a notification. The notification count updates in real-time in the navbar. The commenter does NOT get notified for their own comment.

---

## ERD

```
┌──────────┐       ┌──────────────────┐       ┌──────────┐
│  users   │       │  notifications   │       │ comments │
├──────────┤       ├──────────────────┤       ├──────────┤
│ id       │──┐    │ id               │   ┌───│ id       │
│ email    │  └───>│ user_id          │   │   │ body     │
│ ...      │       │ notifiable_id    │<──┘   │ post_id  │
│          │       │ notifiable_type  │       │ user_id  │
│          │       │ read (boolean)   │       │ ...      │
│          │       │ created_at       │       │          │
└──────────┘       └──────────────────┘       └──────────┘
```

The `notifications` table uses **polymorphic associations** so you can later create notifications for other events (likes, mentions, etc.) without changing the schema.

---

## Steps

### 1. Generate the model

```bash
rails g model Notification user:references notifiable:references{polymorphic} read:boolean
rails db:migrate
```

### 2. Wire up associations

**`app/models/notification.rb`**
```ruby
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }

  after_create_commit :broadcast_count

  private

  def broadcast_count
    broadcast_replace_to(
      "notifications_#{user.id}",
      target: "notification_count",
      partial: "notifications/count",
      locals: { count: user.notifications.unread.count }
    )
  end
end
```

**`app/models/user.rb`** — add:
```ruby
has_many :notifications, dependent: :destroy
```

### 3. Add callback on Comment

**`app/models/comment.rb`** — add:
```ruby
after_create_commit :notify_post_author

private

def notify_post_author
  return if user == post.user  # Don't notify yourself

  Notification.create!(
    user: post.user,
    notifiable: self,
    read: false
  )
end
```

### 4. Create notifications controller

```bash
rails g controller Notifications index --skip-routes
```

**`config/routes.rb`** — add:
```ruby
resources :notifications, only: [:index] do
  member do
    patch :mark_as_read
  end
end
```

**`app/controllers/notifications_controller.rb`**
```ruby
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    current_user.notifications.unread.update_all(read: true)
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    redirect_to notifications_path
  end
end
```

### 5. Add notification badge to navbar

**`app/views/notifications/_count.html.erb`**
```erb
<span id="notification_count">
  <% if count > 0 %>
    <span class="bg-red-500 text-white text-xs rounded-full px-2 py-1"><%= count %></span>
  <% end %>
</span>
```

In your layout navbar, add:
```erb
<% if user_signed_in? %>
  <%= turbo_stream_from "notifications_#{current_user.id}" %>
  <%= link_to notifications_path, class: "relative" do %>
    Notifications
    <%= render "notifications/count", count: current_user.notifications.unread.count %>
  <% end %>
<% end %>
```

### 6. Create notifications index page

**`app/views/notifications/index.html.erb`**
```erb
<div class="max-w-4xl mx-auto py-8">
  <h1 class="text-2xl font-bold mb-6">Notifications</h1>

  <% @notifications.each do |notification| %>
    <div class="border-b py-3 <%= 'bg-blue-50' unless notification.read? %>">
      <% if notification.notifiable.is_a?(Comment) %>
        <p>
          <strong><%= notification.notifiable.user.email %></strong>
          commented on your post
          <%= link_to notification.notifiable.post.title,
              post_path(notification.notifiable.post),
              class: "text-blue-600 hover:underline" %>
        </p>
        <p class="text-gray-500 text-sm"><%= time_ago_in_words(notification.created_at) %> ago</p>
      <% end %>
    </div>
  <% end %>
</div>
```

---

## Test

**`test/models/notification_test.rb`**
```ruby
require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "comment creates notification for post author" do
    post_author = users(:one)
    commenter = users(:two)
    post = posts(:one) # owned by users(:one)

    assert_difference "post_author.notifications.count", 1 do
      Comment.create!(
        body: "Great post!",
        post: post,
        user: commenter
      )
    end

    notification = post_author.notifications.last
    assert_equal false, notification.read
    assert_equal "Comment", notification.notifiable_type
  end

  test "commenter does not get notified for own comment" do
    post_author = users(:one)
    post = posts(:one) # owned by users(:one)

    assert_no_difference "post_author.notifications.count" do
      Comment.create!(
        body: "My own comment",
        post: post,
        user: post_author
      )
    end
  end
end
```

---

## Hints (use only when stuck)

1. **Hint 1** — The `after_create_commit` callback only fires after the database transaction is committed. If you use `after_create`, the broadcast might fail because the record is not yet persisted.
2. **Hint 2** — Make sure `return if user == post.user` is comparing the right things. Both `user` and `post.user` should be User instances.
3. **Hint 3** — The `turbo_stream_from` tag in the layout subscribes the browser to a named stream. The stream name must match what `broadcast_replace_to` uses in the Notification model.
