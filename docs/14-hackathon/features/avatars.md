---
feature: User Avatars
difficulty: "\U0001F7E2 Easy"
teaches: Active Storage, image attachments, view helpers
---

# User Avatars

## Business Need

> Users want a profile picture.

Users can upload an avatar image. The avatar is displayed next to their posts and comments. If no avatar is uploaded, show the user's initials as a fallback.

---

## ERD

No new tables needed. Active Storage uses its own `active_storage_blobs` and `active_storage_attachments` tables (already set up in Rails 8).

```
┌──────────┐       ┌──────────────────────────┐       ┌─────────────────────┐
│  users   │       │ active_storage_attachments│       │ active_storage_blobs│
├──────────┤       ├──────────────────────────┤       ├─────────────────────┤
│ id       │──┐    │ id                       │   ┌───│ id                  │
│ email    │  └───>│ record_id                │   │   │ filename            │
│ ...      │       │ record_type              │   │   │ content_type        │
│          │       │ name ("avatar")          │   │   │ byte_size           │
│          │       │ blob_id                  │<──┘   │ checksum            │
└──────────┘       └──────────────────────────┘       └─────────────────────┘
```

---

## Steps

### 1. Add avatar attachment to User

**`app/models/user.rb`** — add:
```ruby
has_one_attached :avatar
```

No migration needed — Active Storage tables already exist.

### 2. Update Devise permitted parameters

**`app/controllers/application_controller.rb`** — add:
```ruby
before_action :configure_permitted_parameters, if: :devise_controller?

protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
end
```

### 3. Add avatar field to registration edit form

**`app/views/devise/registrations/edit.html.erb`** — add inside the form:
```erb
<div class="mb-4">
  <%= f.label :avatar, class: "block text-sm font-medium text-gray-700" %>
  <%= f.file_field :avatar, accept: "image/*",
      class: "mt-1 block w-full text-sm text-gray-500
             file:mr-4 file:py-2 file:px-4 file:rounded
             file:border-0 file:text-sm file:font-semibold
             file:bg-blue-50 file:text-blue-700
             hover:file:bg-blue-100" %>
  <% if current_user.avatar.attached? %>
    <div class="mt-2">
      <%= image_tag current_user.avatar, class: "w-16 h-16 rounded-full object-cover" %>
    </div>
  <% end %>
</div>
```

### 4. Create an avatar helper partial

**`app/views/shared/_avatar.html.erb`**
```erb
<%# Usage: render "shared/avatar", user: @user, size: "w-10 h-10" %>
<% size ||= "w-10 h-10" %>
<% if user.avatar.attached? %>
  <%= image_tag user.avatar, class: "#{size} rounded-full object-cover inline-block" %>
<% else %>
  <span class="<%= size %> rounded-full bg-gray-300 text-gray-700 flex items-center justify-center text-sm font-bold inline-flex">
    <%= user.email[0].upcase %>
  </span>
<% end %>
```

### 5. Display avatar next to posts

**`app/views/posts/_post.html.erb`** or wherever posts are rendered — add:
```erb
<div class="flex items-center gap-2 mb-2">
  <%= render "shared/avatar", user: post.user, size: "w-8 h-8" %>
  <span class="text-sm text-gray-600"><%= post.user.email %></span>
</div>
```

### 6. Display avatar next to comments

Similarly, wherever comments are rendered:
```erb
<div class="flex items-center gap-2 mb-1">
  <%= render "shared/avatar", user: comment.user, size: "w-6 h-6" %>
  <span class="text-sm text-gray-600"><%= comment.user.email %></span>
</div>
```

---

## Test

**`test/models/user_avatar_test.rb`**
```ruby
require "test_helper"

class UserAvatarTest < ActiveSupport::TestCase
  test "user can upload an avatar" do
    user = users(:one)
    user.avatar.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.png")),
      filename: "avatar.png",
      content_type: "image/png"
    )
    assert user.avatar.attached?
  end

  test "avatar displays on posts" do
    user = users(:one)
    user.avatar.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.png")),
      filename: "avatar.png",
      content_type: "image/png"
    )
    # Avatar should be attached and retrievable
    assert_equal "avatar.png", user.avatar.filename.to_s
  end
end
```

> **Note:** You will need a small test image at `test/fixtures/files/avatar.png`. Create a 1x1 pixel PNG or copy any small image there.

To create a minimal test fixture:
```bash
mkdir -p test/fixtures/files
convert -size 1x1 xc:red test/fixtures/files/avatar.png 2>/dev/null || \
  printf '\x89PNG\r\n\x1a\n' > test/fixtures/files/avatar.png
```

---

## Hints (use only when stuck)

1. **Hint 1** — Did you add `:avatar` to the Devise permitted parameters? Without it, the upload is silently ignored.
2. **Hint 2** — `has_one_attached :avatar` goes in the User model. No migration needed.
3. **Hint 3** — The `accept: "image/*"` on the file field is just a browser hint. For real validation, add `validates :avatar, content_type: [:png, :jpg, :jpeg]` (requires the `active_storage_validations` gem, but this is optional for the hackathon).
