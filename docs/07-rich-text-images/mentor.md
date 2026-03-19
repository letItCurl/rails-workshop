---
branch: 07-rich-text-images
role: mentor
aha_moment: "Two install commands = rich text + file uploads"
driving_force: "See what Rails gives for free"
---

# Mentor Guide — Rich Text + Images

## Teaching Goal

Students should experience the "free stuff" moment — Rails ships with a rich text editor (Action Text) and file storage (Active Storage) built in. Two install commands give them functionality that would take days to set up in other frameworks. This is one of the strongest "Rails magic" moments in the workshop.

---

## Timing Guide (30 minutes total)

| Section | Time | Minutes | Activity |
|---------|------|---------|----------|
| 1. Business question + Action Text install | 14:50–15:00 | 10 | Live code: install Action Text, update model and form, show Trix editor |
| 2. Active Storage install | 15:00–15:08 | 8 | Live code: install Active Storage, add cover image to Post |
| 3. Permit params + demo | 15:08–15:13 | 5 | Update controller, full demo of creating a post with rich text + image |
| 4. Checkpoints + reflection | 15:13–15:20 | 7 | Walk through all 3 checkpoints, comparison with React/Next.js |

---

## Checkpoints with Expected Answers

### Checkpoint 1 (Green) — "How many commands? What was created?"

**Expected answer:**
- 2 commands per feature (`install` + `migrate`)
- `rails action_text:install` created:
  - Migration for `action_text_rich_texts` table
  - Trix editor JavaScript (via importmap or jsbundling)
  - Active Storage migration (if not already present)
  - `app/views/active_storage/blobs/` and `app/views/layouts/action_text/contents/` views

**If students struggle:** Have them look at the terminal output from the install command. It lists every file created.

### Checkpoint 2 (Yellow) — "What tables did Active Storage create?"

**Expected answer:**
- `active_storage_blobs` — metadata about each uploaded file
- `active_storage_attachments` — polymorphic join table connecting blobs to models
- `active_storage_variant_records` — tracks generated image variants

**Key connection:** `active_storage_attachments` is a **join table**, just like `post_tags` from step 06. The pattern is the same: a table with two foreign keys connecting two other tables. Active Storage just makes it polymorphic so any model can have attachments.

### Checkpoint 3 (Red) — "What would you need in React/Next.js?"

**Expected answer (approximate):**
- Rich text: Tiptap/Slate/Quill + configuration + sanitization
- Upload: multer/formidable + S3 SDK + presigned URLs
- Storage: S3 bucket + IAM + CORS
- Processing: sharp/imagemagick
- Frontend: upload UI + progress + preview

Let students brainstorm this. The longer the list gets, the stronger the aha moment.

---

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `MiniMagick::Error` or `Vips::Error` when displaying images | Missing libvips or ImageMagick on the system | `brew install vips` (macOS) or `apt install libvips-dev` (Linux) |
| Trix editor not appearing in the form | Importmap not loading Action Text JS | Run `rails action_text:install` again, check `app/javascript/application.js` has `import "trix"` and `import "@rails/actiontext"` |
| `ActiveRecord::StatementInvalid` on file upload | Active Storage tables don't exist — forgot to run migrate | `rails db:migrate` |
| Image uploaded but not displaying on show page | Missing `image_tag` or not checking `.attached?` | Use `<%= image_tag @post.cover_image if @post.cover_image.attached? %>` |
| `image_processing` gem error on variants | Missing the `image_processing` gem | Add `gem "image_processing", "~> 1.2"` to Gemfile, `bundle install` |
| Form submits but cover_image not saved | `:cover_image` not in permitted params | Add `:cover_image` to `post_params` permit list |

---

## Aha Moment Setup

The key moment to orchestrate:

> "We just got a full rich text editor with bold, italic, links, lists, headings, AND file uploads with image display... from two install commands. In React, what would you need?"

Let students list everything: npm packages, S3 config, IAM policies, CORS, presigned URLs, upload components, progress bars, sanitization... Watch their faces as the list grows.

Then land it: **"This is what 'convention over configuration' means in practice. Rails made these decisions for you."**

---

## Connection to Previous Lessons

**Active Storage attachments = another join table.** Make this connection explicit:

- Step 06: `post_tags` is a join table connecting `posts` and `tags`
- Step 07: `active_storage_attachments` is a join table connecting any model to `active_storage_blobs`
- The difference: Active Storage uses **polymorphic associations** (`record_type` + `record_id`) so one table works for every model

If students are curious about polymorphic associations, briefly explain that `record_type` stores the class name ("Post") and `record_id` stores the ID. This is how one join table serves all models. Don't go deep — just plant the seed.

---

## Notes

- If students are on Apple Silicon and hit libvips issues, `brew install vips` should resolve it
- The Trix editor is intentionally simple — Rails chose simplicity over feature-richness. If students ask about more advanced editors, acknowledge it and note that the community has gems for other editors
- Active Storage defaults to local disk storage in development. In production you'd configure S3/GCS/Azure in `config/storage.yml` — mention this but don't configure it now
