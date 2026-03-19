---
branch: 12-turbo-streams
title: "Turbo Streams — Real-time Without JS"
lang: en
pair: guide-th.md
day: 2
time: "11:15–12:00"
duration: 45min
difficulty: "\U0001F534 Challenge"
prerequisite: 11-turbo-frames
next: 12-turbo-deep-dive
rails_guide:
  - https://guides.rubyonrails.org/working_with_javascript_in_rails.html
  - https://guides.rubyonrails.org/action_cable_overview.html
aha_moment: "Real-time updates — 2 lines of code, zero JavaScript"
business_rule: "New comments appear instantly for everyone viewing the same post"
---

# Turbo Streams — Real-time Without JS

## The Scenario

You're reading a post. Someone else comments on it — do you have to refresh?

In React, you'd need to set up a WebSocket connection, manage state subscriptions, handle component re-renders... how many hundreds of lines? How many extra libraries?

In Rails 8, it takes **2 lines of code**. No JavaScript required.

---

## What Are Turbo Streams?

Turbo Streams let the server **push HTML fragments** to the browser over WebSocket. The browser receives the HTML and automatically inserts, replaces, or removes DOM elements.

No JS to write. No JSON to parse. No state to manage — the server sends finished HTML directly.

---

## Step 1: Create the Comment Partial

Create `app/views/comments/_comment.html.erb`:

```erb
<%= turbo_frame_tag comment do %>
  <div class="comment-card">
    <div class="comment-body">
      <%= simple_format(comment.body) %>
    </div>
    <div class="comment-meta">
      <span class="comment-date"><%= time_ago_in_words(comment.created_at) %> ago</span>
      <%= button_to "Delete", post_comment_path(comment.post, comment),
            method: :delete,
            class: "btn-delete-comment" %>
    </div>
  </div>
<% end %>
```

Why a partial? Because `broadcasts_to` uses this partial to render the HTML it broadcasts to everyone. The filename must match the model — `_comment.html.erb` for `Comment`.

---

## Step 2: Update the Show View

Open `app/views/posts/show.html.erb` and add two things:

**2a.** Add `turbo_stream_from` **before** the comments div:

```erb
<%= turbo_stream_from @post %>
```

This tells the browser: "subscribe to the WebSocket channel for this post."

**2b.** Change the comments loop to use the partial:

```erb
<div id="comments">
  <%= render @post.comments %>
</div>
```

`render @post.comments` automatically renders `_comment.html.erb` for each comment.

---

## Step 3: broadcasts_to in the Comment Model

Open `app/models/comment.rb` and add **one line**:

```ruby
class Comment < ApplicationRecord
  belongs_to :post

  broadcasts_to :post
end
```

That's it. `broadcasts_to :post` tells Rails: "whenever a comment is created or destroyed, broadcast the HTML to everyone viewing that same post."

---

## Step 4: Test It!

1. Open 2 browser tabs on the same post
2. Type a comment in tab A and submit
3. Watch tab B — the new comment appears **instantly** without refreshing!
4. Delete the comment in tab A — it disappears from tab B too

**It actually works — real-time, zero JavaScript.**

---

## Under the Hood: How broadcasts_to Works

1. `turbo_stream_from @post` creates a WebSocket subscription to an Action Cable channel specific to that post
2. When a comment is created, `broadcasts_to :post`:
   - Renders the `_comment.html.erb` partial
   - Wraps it in a `<turbo-stream action="append">` message
   - Broadcasts that HTML over WebSocket to all subscribers
3. Subscribed browsers receive the HTML and append it to the DOM automatically
4. When a comment is destroyed, it broadcasts `<turbo-stream action="remove">` instead

Rails handles all of this for you.

---

## Rails 8 Note: Solid Cable

Rails 8 uses **Solid Cable** as the default Action Cable adapter — no Redis needed! It uses the database as a pub/sub backend instead. The config lives in `config/cable.yml` and works out of the box.

---

## Checkpoints

### Checkpoint 1 (Green)

What does `broadcasts_to :post` do? What one line do you add to the view?

> `broadcasts_to :post` makes Rails broadcast HTML to everyone viewing the same post when a comment is created or destroyed.
> In the view, add `turbo_stream_from @post` to subscribe.

### Checkpoint 2 (Yellow)

Open 2 tabs and comment in one — does it appear in the other? What technology makes this possible?

> Yes, it appears instantly. The technology is WebSocket via Action Cable (Solid Cable in Rails 8).

### Checkpoint 3 (Red)

What would you need to set up in React to get real-time updates like this?

> WebSocket connection management, state subscription/unsubscription, JSON parsing, component re-rendering, cleanup on unmount, error handling/reconnection... at least 4-5 files and 2-3 extra libraries.

---

## If Stuck

Common issues:

- **Comments don't broadcast**: Check that Action Cable is mounted in `config/routes.rb` (`mount ActionCable.server => '/cable'`)
- **Partial not found error**: The filename must be `_comment.html.erb` matching the `Comment` model, located in `app/views/comments/`
- **turbo_stream_from not subscribing**: Place `turbo_stream_from @post` **before** the comments div, not after
- **Comment appears twice**: Both the broadcast and the turbo stream response from the controller fire at the same time — you need to handle this in the controller
- **Delete doesn't disappear in other tabs**: Check `dependent: :destroy` in the Post model or verify the `after_destroy` callback is correct

---

## Self-Check

If you've made it this far, you have real-time updates working with just 2 lines of code:

1. `broadcasts_to :post` in the model
2. `turbo_stream_from @post` in the view

**But how does it actually work?** How is the Action Cable channel created? Where does the HTML get rendered? What does the WebSocket message look like?

After the break, we'll dig into every layer in **Turbo Streams Deep Dive**.
