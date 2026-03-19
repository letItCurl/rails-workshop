---
branch: 11-turbo-frames
title: "Turbo Frames — Inline Editing Without JS"
lang: en
pair: guide-th.md
day: 2
time: "10:00–11:00"
duration: 60min
difficulty: "\U0001F534 Challenge"
prerequisite: 10-day2-start
next: 12-turbo-streams
rails_guide: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
aha_moment: "Inline editing with HTML tags — no JavaScript"
business_rule: "Draft posts can be edited inline without reload"
---

# Turbo Frames — Inline Editing Without JS

## Opening: Think About React First

How do you do inline editing in React?

`useState` to toggle between view mode and edit mode. `fetch` to send data to the API. DOM manipulation to swap components. Re-render logic to update the UI. How many lines? 30? 50? 100?

Today you'll do the exact same thing — **without writing a single line of JavaScript**. No useState. No fetch. No useEffect. Just HTML tags.

---

## What Is a Turbo Frame?

It's an HTML tag:

```html
<turbo-frame id="post_42">
  <!-- content goes here -->
</turbo-frame>
```

That's it. `<turbo-frame>` tells the browser **"only replace this section"**. When the user navigates within a frame, only the content inside the frame changes — the rest of the page doesn't move.

The header doesn't reload. The sidebar doesn't disappear. Flash messages don't flash. **Only the frame changes.**

Rails gives you a helper to create this tag:

```erb
<%= turbo_frame_tag @post do %>
  <!-- content -->
<% end %>
```

This generates `<turbo-frame id="post_42">` automatically (using model name + id).

---

## The Plan

Here's the overview of what we'll do:

1. **show.html.erb** — wrap post content with `turbo_frame_tag @post`
2. **edit.html.erb** — wrap the form with `turbo_frame_tag @post` (same ID!)
3. User clicks "Edit inline" → Turbo fetches the edit page → extracts only the matching frame → **form appears in place of content**
4. User submits → controller redirects back to show → Turbo extracts frame → **content updates**

All of this without a page reload. No JavaScript. Just HTML attributes.

> **Business rule:** Only **draft posts** can be edited inline. Published posts are immutable. Comments can never be edited.

---

## Step-by-step

### Step 1: Wrap post content in show.html.erb

Open `app/views/posts/show.html.erb` and wrap the post content section with a turbo frame:

```erb
<%= turbo_frame_tag @post do %>
  <h1><%= @post.title %></h1>
  <div><%= @post.body %></div>

  <% if @post.draft? && @post.user == current_user %>
    <%= link_to "Edit inline", edit_post_path(@post) %>
  <% end %>
<% end %>
```

Important: **The Edit link must be inside the frame.** If the link is outside the frame, Turbo won't intercept the click — it will do a full page navigation instead.

### Step 2: Wrap the form in edit.html.erb

Open `app/views/posts/edit.html.erb` and wrap the form with a **matching** turbo frame:

```erb
<%= turbo_frame_tag @post do %>
  <%= render "form", post: @post %>

  <%= link_to "Cancel", post_path(@post) %>
<% end %>
```

**KEY:** `turbo_frame_tag @post` in both show and edit must generate the **same ID**. If show has `id="post_42"` but edit has `id="edit_post_42"` — it won't work.

### Step 3: Edit link must be inside the frame

Double-check that the "Edit inline" link is **inside** the `turbo_frame_tag` block in show.html.erb. If it's outside, Turbo will let the browser navigate normally (full page reload).

### Step 4: Cancel link

The Cancel link in edit.html.erb must also be **inside** the frame. When the user clicks Cancel, Turbo will fetch the show page, extract the frame, and replace the form back with the original content.

```erb
<%= link_to "Cancel", post_path(@post) %>
```

Dead simple. Just a normal link. Turbo handles everything.

### Step 5: Test it

1. Navigate to one of your draft posts
2. Click "Edit inline"
3. The form should appear **in place** — no redirect to another page
4. Edit the title or body
5. Click submit
6. The content updates **in place** — no page reload
7. Click "Edit inline" again, then click "Cancel"
8. The form disappears and the original content returns

---

## KEY WARNING: Frame IDs Must Match

This is the **most common error** in this step.

`turbo_frame_tag @post` generates `<turbo-frame id="post_42">` — both show.html.erb and edit.html.erb must generate the **same ID**.

If the IDs don't match:
- Turbo fetches the edit page
- It looks for `<turbo-frame id="post_42">` and doesn't find it
- **Nothing happens** (or the frame content disappears entirely)

Open DevTools → Network tab → inspect the response of the edit request → verify the `<turbo-frame id="...">` matches.

---

## Under the Hood: How It Works

1. User clicks a link that is **inside** a `<turbo-frame>`
2. Turbo **intercepts** the click (prevents normal browser navigation)
3. Turbo sends a **fetch request** to the link's URL
4. The server responds with a full HTML page (as usual)
5. Turbo **extracts** only the `<turbo-frame>` with the matching ID from the response
6. Turbo **replaces** the content of the original frame with the extracted content
7. The rest of the page is **untouched**

This is why:
- IDs must match (step 5 won't find the frame)
- Links must be inside the frame (step 1 won't intercept)
- The controller doesn't need changes (the server responds with a full page as normal)

---

## Checkpoints

### Checkpoint 1 (green)

What HTML does `turbo_frame_tag @post` generate?

Which attribute tells Turbo which section of the page to replace?

> Try it: open DevTools → Inspect element → look at the generated tag

---

### Checkpoint 2 (yellow)

What happens if the frame ID in show.html.erb is `post_42` but in edit.html.erb it's `edit_post`?

> Try it: change edit to use `turbo_frame_tag "wrong_id"` and see what happens

---

### Checkpoint 3 (red)

If you had to build this same inline editing in React:

- How many `useState` hooks would you need?
- How many `fetch` calls?
- How would you manage the DOM?
- How complex would the re-render logic be?

Compare that to what you just did — **added an HTML tag in 2 places and you're done**.

---

## Stuck? Read This

This is the hardest step in the workshop. Don't worry if you're stuck — everyone gets stuck here.

### If clicking Edit causes a full page reload

- The Edit link is **outside** the `turbo_frame_tag` block → move it inside
- Frame IDs don't match → open DevTools and check the `<turbo-frame id="...">` on both pages
- Turbo isn't imported → check `application.js` for Turbo

### If the form doesn't appear

- edit.html.erb doesn't have a `turbo_frame_tag` → add `turbo_frame_tag @post` wrapping the form
- The frame ID in edit doesn't match show → use `turbo_frame_tag @post` in both (don't hardcode strings)
- DevTools → Network → inspect the response of the edit request → look for the `<turbo-frame>` tag

### If submitting doesn't return to show

- The controller must use `redirect_to @post`, not `render :show`
- If you `render`, Turbo gets a 200 response without a redirect → the frame gets stuck
- Check `posts_controller.rb`, the `update` method

### If Cancel doesn't work

- The Cancel link must be **inside** the `turbo_frame_tag` block in edit.html.erb
- If it's outside the frame, the click will do a full page navigation

### If content outside the frame disappears

- Make sure you wrap **only the section that should be editable**, not the entire page
- The comment section, tags, and author info should be **outside** the frame

### If you can edit published posts

- Check authorization — only draft posts should show the Edit link
- The controller should check `@post.draft?` before allowing edits

### If nothing works at all

- Start over from the minimal case: add `turbo_frame_tag @post` in show + edit — just 2 places
- Get the basic case working first, then add Cancel, styling, authorization

---

## What You Learned

- `turbo_frame_tag` creates a `<turbo-frame>` that scopes navigation to just that frame
- Frame IDs must match between the source page and the target page
- Links and forms inside the frame are intercepted by Turbo automatically
- No JavaScript needed — everything is HTML attributes
- Business rule: only draft posts can be edited inline

## Up Next

Next step: **Turbo Streams** — real-time updates pushed from the server to the browser. If Turbo Frames are "user clicks, frame changes," Turbo Streams are "server pushes, page updates on its own."
