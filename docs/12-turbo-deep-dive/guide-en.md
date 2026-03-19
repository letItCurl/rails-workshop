---
branch: 12-turbo-deep-dive
title: "Deep Dive — How Turbo Actually Works"
lang: en
pair: guide-th.md
day: 2
time: "12:00–12:15"
duration: 15min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 12-turbo-streams
next: 13-stimulus
rails_guide: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
aha_moment: "HTML over the wire — no JSON, no JS, just HTML fragments"
---

# Deep Dive — How Turbo Actually Works

You built inline editing and real-time comments. They work. But do you know what is actually happening under the hood?

No new code in this step. We are opening the lid to see what Turbo does behind the scenes.

---

## The Golden Rule

Every non-GET request (POST, PATCH, DELETE) goes through Turbo automatically.

- Forms are intercepted by Turbo — no full page reload
- Clicks inside a `<turbo-frame>` are intercepted — Turbo fetches only that frame
- You don't have to do anything — Turbo handles it

You write normal HTML. Rails renders normal HTML. But Turbo decides where to put the HTML in the DOM.

---

## Exercise: DevTools Network Tab

Follow along:

1. Open DevTools (`Cmd+Opt+I` on Mac) and go to the **Network** tab
2. Navigate to a draft post and click **"Edit inline"**
3. Look at the request — Turbo is fetching the edit page

Look at the response carefully — **it is a full HTML page!** Complete with `<html>`, `<head>`, `<body>`.

But Turbo does not use the whole page. It extracts only the `<turbo-frame id="post_123">` whose ID matches the frame on the current page.

The rest? **Thrown away.** Only the matching part is used.

Here is the full process:
1. User clicks Edit inside `<turbo-frame id="post_42">`
2. Turbo intercepts the click, fires GET `/posts/42/edit`
3. Server renders `edit.html.erb` as a full page (as usual)
4. Turbo receives the HTML, searches for `<turbo-frame id="post_42">` in the response
5. Found it! Swaps the content into the existing frame in the DOM
6. Everything else in the response is discarded

---

## What if no matching ID?

Try this experiment: change the ID in `edit.html.erb` to something else, like `post_wrong`.

Click Edit again — **the content disappears!**

Turbo cannot find a matching frame, so it inserts empty content.

This is a very common bug — if the IDs do not match, content vanishes silently with no error.

> Don't forget to revert afterwards!

---

## Turbo Streams format

Turbo Frames always need matching IDs. **Turbo Streams** are different.

When the server responds with a `.turbo_stream` format instead of regular HTML:

```html
<turbo-stream action="append" target="comments">
  <template>
    ...comment partial HTML...
  </template>
</turbo-stream>
```

Turbo reads:
- **action** — what to do: `append`, `prepend`, `replace`, `remove`, `update`
- **target** — which DOM element (by id)

And executes it. No frame matching needed — **it tells the browser exactly what to change**.

Streams = instructions from the server saying "take this HTML and append it to the element with this id."

---

## broadcasts_to under the hood

The `broadcasts_to :post` we added to the Comment model — what does it actually do?

**What really happens:**

1. `broadcasts_to :post` registers **after_create** and **after_destroy** callbacks in ActiveRecord
2. When a comment is created:
   - Rails renders the `_comment.html.erb` partial
   - Wraps it in `<turbo-stream action="append" target="comments">`
   - Pushes it via **Action Cable WebSocket** to every browser that is subscribed
3. When a comment is destroyed:
   - Pushes `<turbo-stream action="remove" target="comment_123">`
   - No rendering needed — just tells the browser to remove it

**`turbo_stream_from @post`** in the view creates a WebSocket subscription to a channel named after the post.

Every browser viewing the same post subscribes to the same channel. When a new comment arrives, everyone receives the same HTML fragment.

---

## Exercise: DevTools WS tab

Follow along:

1. Open DevTools, go to **Network** tab, filter by **WS** (WebSocket)
2. Refresh the post page — you will see a WebSocket connection to `/cable`
3. Click into it — look at the **Messages** tab
4. Open another browser tab (or incognito) and navigate to the same post
5. Post a comment from the second tab
6. Switch back to the first tab and watch the message that was pushed in

**It is HTML!** Not JSON, not data — a ready-to-use HTML fragment.

---

## The Full Picture

Now we can see the complete landscape:

**Turbo Drive** — intercepts every link click and form submit, fetches HTML, replaces the entire `<body>`

**Turbo Frames** — intercepts within a box, fetches HTML, replaces only the `<turbo-frame>` with a matching ID

**Turbo Streams** — server pushes or responds with HTML fragments, using actions: append / prepend / replace / remove / update

**All of it = HTML over the wire**

No JSON API. No client-side rendering. No state management.

Server renders HTML. Sends it to the browser. Browser puts it in the DOM.

This is the Hotwire philosophy: **the server renders everything, the browser just displays it.**

---

## Checkpoints

### Checkpoint 1
What do all non-GET requests go through?

### Checkpoint 2
If the turbo-frame ID on the show page does not match the ID on the edit page, what happens?

### Checkpoint 3
What callbacks does `broadcasts_to` register? What does it push over WebSocket?

### Checkpoint 4
What is the difference between Turbo Frames and Turbo Streams?
