---
branch: 07-rich-text-images
title: "Rich Text + Images — Free Stuff from Rails"
lang: en
pair: guide-th.md
day: 1
time: "14:50–15:20"
duration: 30min
difficulty: "\U0001F7E2 Recipe"
prerequisite: 06-tags-deep-dive
next: 08-team-survival
rails_guide:
  - https://guides.rubyonrails.org/action_text_overview.html
  - https://guides.rubyonrails.org/active_storage_overview.html
aha_moment: "Rich text + file uploads — zero custom code"
business_rule: "Posts have a rich text body + cover image"
---

# Rich Text + Images — Free Stuff from Rails

## Business Question

"Plain text is boring. Users want rich text and images. How many days do you think that'll take?"

With most frameworks, the answer might be "a couple of days, maybe?" But Rails ships with batteries included. Let's see how fast we can do this.

---

## 1. Install Action Text

Action Text is built right into Rails. No extra gems needed. Just run:

```bash
rails action_text:install
rails db:migrate
```

Two commands. That's it. Here's what Rails created for us:

- **action_text_rich_texts table** — stores rich text content separately from the main model
- **Trix editor JS** — a full rich text editor bundled with Rails, complete with bold, italic, links, lists, everything
- **Active Storage migration** — created automatically if not already present (because rich text supports embedded images)

### Update the Post model

Open `app/models/post.rb` and swap the plain text field for rich text:

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  # ... existing code ...
end
```

You don't need to remove the old `body` column — `has_rich_text` uses the `action_text_rich_texts` table instead. But if you want to clean up, you can create a migration to drop the old column.

### Update the form

Open `app/views/posts/_form.html.erb` and change the body field:

```erb
<%= form.rich_text_area :body %>
```

That's literally it. Open your browser and you'll see a **full WYSIWYG editor** with a toolbar for bold, italic, headings, lists, links — the works.

---

## 2. Install Active Storage

Next, we want Posts to have a cover image. Active Storage is the answer:

```bash
rails active_storage:install
rails db:migrate
```

> Note: If `rails action_text:install` already created the Active Storage migration, this step may be redundant. Running it again is harmless.

### Add the attachment to the Post model

```ruby
class Post < ApplicationRecord
  has_rich_text :body
  has_one_attached :cover_image
  # ... existing code ...
end
```

### Add a file field to the form

```erb
<div>
  <%= form.label :cover_image %>
  <%= form.file_field :cover_image %>
</div>
```

### Display the image on the show page

```erb
<% if @post.cover_image.attached? %>
  <%= image_tag @post.cover_image %>
<% end %>
```

---

## 3. Permit params

Don't forget to update strong params in `PostsController`:

```ruby
def post_params
  params.require(:post).permit(:title, :body, :published, :cover_image, tag_ids: [])
end
```

`:body` now comes from Action Text, but you still permit it the same way. `:cover_image` is the new addition.

---

## Checkpoints

### Checkpoint 1 (Green)

> How many commands did it take? What did `rails action_text:install` create?

- **2 commands** (`install` + `migrate`) for each feature
- Created the `action_text_rich_texts` table, Trix editor JS, and Active Storage migration (if not already present)

### Checkpoint 2 (Yellow)

> What tables did Active Storage create?

- **active_storage_blobs** — stores file metadata (filename, content type, size, checksum)
- **active_storage_attachments** — connects a blob to the model it's attached to. It's **another join table**!

Notice the pattern? Same thing as `post_tags` from the previous step — Active Storage uses a polymorphic join table to connect blobs to any model.

### Checkpoint 3 (Red)

> In React/Next.js, what would you need to do to get a rich text editor + file upload?

Think about it:

- **Rich text editor**: Choose a library (Tiptap, Slate, Draft.js, Quill), install npm packages, configure the toolbar, handle serialization/deserialization, manage HTML sanitization
- **File upload**: Set up multer or formidable on the server, choose storage (S3, GCS, local), configure presigned URLs, handle multipart uploads
- **S3 setup**: Create a bucket, IAM policy, CORS config, environment variables
- **Image processing**: Install sharp or imagemagick, write resize logic
- **Frontend**: Build an upload component, progress bar, drag & drop, preview

All of that comes free with Rails in **2 install commands**.

---

## Self-check

- [ ] Post form shows a rich text editor (Trix)
- [ ] You can bold, italic, and create lists in the body
- [ ] You can upload a cover image
- [ ] Cover image displays on the show page
- [ ] Everything works with the existing Devise authentication + authorization

## Next Up

Next step: **08-team-survival** — we'll learn about working as a team with Git, conflict resolution, and real-world workflows.
