---
branch: 06-tags
title: "Tags — has_many :through"
lang: en
pair: guide-th.md
day: 1
time: "13:50–14:35"
duration: 45min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 05-polish
next: 07-rich-text-images
rails_guide: https://guides.rubyonrails.org/association_basics.html#the-has-many-through-association
aha_moment: "has_many :through — two lines handle everything"
business_rule: "A post has many tags, a tag belongs to many posts"
---

# Tags — has_many :through

This is the most important step in the entire workshop. Join tables and `has_many :through` are a pattern you will use everywhere, whether you stay in Rails or not.

---

## 1. Business Question

You have 100 posts with no categories. How do you find anything?

If a user wants to find posts about "Rails," do they scroll through every single one?

**Pause 3 minutes:** Draw the relationship between Post and Tag on paper. Don't think about code yet — just think about how the data connects.

---

## 2. Why — Why a Join Table?

The first thought many people have is "just store tags as a JSON array in Post" — something like `["Rails", "Ruby", "Testing"]`.

The problems:
- Hard to query — `WHERE tags LIKE '%Rails%'` is unreliable
- Doesn't scale — if you want to rename a tag, you have to update every row
- No good indexes — slow queries as data grows

**A join table is the correct approach** because relational databases are designed to JOIN data between tables.

---

## 3. Hands-on: Create the Tag Model

```bash
rails g scaffold Tag name:string
rails db:migrate
```

Open `db/schema.rb` and look — you now have a `tags` table with just a `name` column. Simple.

---

## 4. Join Table: PostTag

This is the key — we need a table in the middle that connects Post and Tag.

```bash
rails g model PostTag post:references tag:references
rails db:migrate
```

Open `db/schema.rb` again — the `post_tags` table has only `post_id` and `tag_id` (plus id and timestamps). That's it. There is no business data in this table. Its only job is to "connect."

---

## 5. Wire the Models

Open `app/models/post.rb`:

```ruby
has_many :post_tags
has_many :tags, through: :post_tags
```

Open `app/models/tag.rb`:

```ruby
has_many :post_tags
has_many :posts, through: :post_tags
```

Open `app/models/post_tag.rb`:

```ruby
belongs_to :post
belongs_to :tag
```

Two lines in Post, two lines in Tag — that's all it takes. Rails handles the entire JOIN for you.

---

## 6. Console SQL — See What Rails Does

Open `rails console` and try:

```ruby
post = Post.first
tag = Tag.create!(name: "Rails")

# Add a tag to a post
post.tags << tag

# See the post's tags — watch the SQL Rails generates
post.tags

# Reverse direction — see a tag's posts
tag.posts
```

**Watch the SQL** that the console prints — you will see `INNER JOIN post_tags ON ...`. This is what `has_many :through` does for you. No hand-written SQL needed.

---

## Checkpoint 1 (Green)

Close your editor and answer these 3 questions without looking at code:

1. What columns does the `post_tags` table have?
2. Why do we need a separate table? Why not store tags directly in Post?
3. If a post has 3 tags, how many rows exist in `post_tags`?

---

## 7. Form: Select Tags

In `app/views/posts/_form.html.erb` add:

```erb
<div>
  <%= form.label :tag_ids, "Tags" %>
  <%= form.collection_check_boxes(:tag_ids, Tag.all, :id, :name) do |b| %>
    <label class="inline-flex items-center mr-4">
      <%= b.check_box class: "rounded border-gray-300" %>
      <span class="ml-2"><%= b.text %></span>
    </label>
  <% end %>
</div>
```

In `posts_controller.rb` don't forget to permit:

```ruby
params.require(:post).permit(:title, :body, :published, tag_ids: [])
```

This is critical: `tag_ids: []` must be an array — if you write just `:tag_ids` it will be unpermitted.

---

## 8. Show Tags — Tailwind Badges

In `app/views/posts/show.html.erb`:

```erb
<div class="flex flex-wrap gap-2 mt-2">
  <% @post.tags.each do |tag| %>
    <span class="inline-block bg-indigo-100 text-indigo-800 text-xs font-semibold px-2.5 py-0.5 rounded-full">
      <%= tag.name %>
    </span>
  <% end %>
</div>
```

---

## 9. Seed Tags

In `db/seeds.rb` add:

```ruby
%w[Ruby Rails Database Testing Hotwire].each do |name|
  Tag.find_or_create_by!(name: name)
end
```

Then run `rails db:seed`.

---

## Checkpoint 2 (Yellow)

Predict the SQL for this query — **write it on paper first**, don't open the console:

```ruby
Post.joins(:tags).where(tags: { name: "Rails" })
```

What SQL will Rails generate? Which tables JOIN with which? Write it out, then open the console to check.

---

## Checkpoint 3 (Red)

Write a test from scratch that proves the association works bidirectionally:

- Create a post, create a tag
- Add the tag to the post
- Assert that `post.tags` includes that tag
- Assert that `tag.posts` includes that post

Try writing it yourself. Ask the mentor if you get stuck.

---

## 10. Reflection

Where else can you use `has_many :through`?

- **Student - Course:** A student takes many courses, a course has many students. Join table: `enrollments`
- **Order - Product:** An order has many products, a product is in many orders. Join table: `order_items` (with quantity!)
- **User - Role:** A user has many roles, a role has many users. Join table: `user_roles`

Think about your React projects — where do you have many-to-many relationships? How did you handle them? How does that compare to the Rails approach?

---

## Self-check

- [ ] Tag scaffold works with full CRUD
- [ ] `post_tags` table has correct foreign keys
- [ ] `Post.first.tags` returns tags
- [ ] `Tag.first.posts` returns posts (bidirectional)
- [ ] Form has checkboxes for selecting tags
- [ ] `tag_ids` is permitted as an array
- [ ] Show page displays tag badges
- [ ] Seeds create 5 tags
- [ ] Passed Checkpoint 1 (Green)
- [ ] Passed Checkpoint 2 (Yellow)
- [ ] Passed Checkpoint 3 (Red)

---

## Next Up

Next step: **07-rich-text-images** — we will use Action Text and Active Storage to give posts rich content and images.
