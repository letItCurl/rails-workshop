---
branch: 12-turbo-challenge
title: "Turbo Challenge — Do It Yourself"
role: mentor
guides:
  - guide-th.md
  - guide-en.md
day: 2
time: "12:00–12:15"
duration: 15min
difficulty: 🔴 Challenge
prerequisite: 12-turbo-deep-dive
next: 13-stimulus
aha_moment: "I can apply Turbo on my own"
driving_force: "Independence — prove you can do it without step-by-step"
progress_file: ./progress.md
---

# Mentor Guide: 12-turbo-challenge

## Teaching Goal

Students prove they can apply Turbo Frames + Streams to a NEW page without step-by-step guidance. This is the independence test — can they transfer what they learned?

**Do NOT give answers.** Let them struggle. Only reveal hints one at a time.

---

## Timing Guide

| Section | Time | Notes |
|---------|------|-------|
| Explain the challenge | 2 min | Read the two challenges, no hints yet |
| Students work | 10 min | Walk around, answer questions with questions |
| Review + checkpoints | 3 min | Quick check, discuss answers |

---

## Challenge 1: Expected Solution — Frames on Index

**Index view (`index.html.erb`):**
Wrap each post article in `turbo_frame_tag post`:
```erb
<%= turbo_frame_tag post do %>
  <article>
    <%= link_to post_path(post) do %>
      <h2><%= post.title %></h2>
    <% end %>
    <p><%= post.excerpt %></p>
  </article>
<% end %>
```

**Show view (`show.html.erb`):**
The existing `turbo_frame_tag @post` already contains the full content. Add a Close link INSIDE the frame:
```erb
<%= turbo_frame_tag @post do %>
  <div class="prose">
    <%= @post.body %>
  </div>
  <%= link_to "Close", posts_path, class: "..." %>
<% end %>
```

**How it works:**
1. Click title → Turbo fetches `/posts/1` → extracts `<turbo-frame id="post_1">` → replaces the card
2. Click Close → Turbo fetches `/posts` → extracts `<turbo-frame id="post_1">` from the index → replaces full content with card

**Key insight:** Close links to `posts_path` (index) not `post_path` because Turbo needs to fetch the INDEX page to get the compact card version of this post's frame.

---

## Challenge 2: Expected Solution — Streams on Index

**Post model:**
```ruby
broadcasts_to ->(post) { "posts" }
```

Note: This uses a lambda because we're broadcasting to a fixed channel name "posts" (not per-post like comments which use `broadcasts_to :post`).

**Index view:**
Add before the posts div:
```erb
<%= turbo_stream_from "posts" %>
```

**The partial `_post.html.erb`** already has `turbo_frame_tag post` — broadcasts will render this partial and append it.

**Potential issue:** The broadcast triggers on ALL create/update/destroy — including drafts. Students might want to scope it to only published posts. That's an advanced consideration — accept any working solution for now.

---

## Checkpoint Answers

**Q1: Why must Close be inside the frame?**
Because Turbo only intercepts clicks INSIDE a `<turbo-frame>`. If Close is outside, it does a full page navigation.

**Q2: Why link to posts_path not post_path?**
Because Turbo needs to fetch a page that contains `<turbo-frame id="post_1">` with the COMPACT version. The index page has the card. The show page has the full content — linking to show would just reload the full content.

**Q3: How is `broadcasts_to ->(post) { "posts" }` different?**
- `broadcasts_to :post` → channel name derived from the associated post object (e.g., `post_123`). Used for comments — each post has its own channel.
- `broadcasts_to ->(post) { "posts" }` → lambda returns a fixed string "posts". ALL posts broadcast to ONE channel. Used for the index — everyone watching the index subscribes to the same channel.

---

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Click title navigates to show page | Link is outside turbo_frame_tag | Move link inside the frame |
| Close shows full content again | Close links to post_path (show) | Change to posts_path (index) |
| Close shows blank | Frame ID mismatch between show and index | Verify both use `turbo_frame_tag post/@ post` |
| New posts don't appear | Missing turbo_stream_from "posts" | Add to index before the posts div |
| ALL changes broadcast (not just publish) | broadcasts_to fires on all saves | Acceptable for challenge — advanced: use after_commit callback |

---

## Progress Logging

```markdown
## Branch 12-turbo-challenge
### Challenge 1: Frames on Index
- Expand works: [✅/❌]
- Close works: [✅/❌]
- Hints used: [0/1/2/3/4]

### Challenge 2: Streams on Index
- Real-time works: [✅/❌]
- Hints used: [0/1/2/3/4]

### Quick Check
- Q1 (Close inside frame): [✅/❌]
- Q2 (posts_path not post_path): [✅/❌]
- Q3 (lambda vs symbol): [✅/❌]

### Interaction Log

### Branch Summary
- started:
- finished:
- completed:
- total_questions:
- independence_score:
- understanding_score:
- curiosity_score:
```
