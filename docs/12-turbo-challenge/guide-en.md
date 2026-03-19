---
branch: 12-turbo-challenge
title: "Turbo Challenge — Real-time Index"
lang: en
pair: guide-th.md
day: 2
time: "12:00–12:15"
duration: 15min
difficulty: 🔴 Challenge
prerequisite: 12-turbo-deep-dive
next: 13-stimulus
aha_moment: "I can use Turbo Streams on my own"
business_rule: "New posts appear real-time on everyone's index"
---

# Turbo Challenge — Real-time Index

## The Challenge

Right now our blog system works fine — you can create posts and view the list. But if someone creates a new post, other people viewing the index page won't see it until they refresh.

**Goal:** Make the index page real-time — when anyone creates a new post, it appears on everyone's index page instantly without a refresh.

## What You Need To Do

You need to figure out the solution yourself, but here's a hint: there are 3 places you need to touch:

1. **View** — The index page needs to subscribe to a stream
2. **Model** — The Post model needs to broadcast when a new record is created
3. **Partial** — The partial must support broadcasting (it needs `dom_id`)

## Testing

1. Open 2 tabs on the posts index page
2. In tab A, create a new post
3. Check tab B — the new post should appear without refreshing

---

## Hints

Open one at a time, only when you're truly stuck.

<details>
<summary>Hint 1 — Where to start?</summary>

Start with the view — the index page needs to subscribe to a channel called `"posts"`. Look for a Turbo helper that does this.

</details>

<details>
<summary>Hint 2 — How to subscribe?</summary>

Add `turbo_stream_from "posts"` to your `index.html.erb` — this line creates a WebSocket subscription to the channel named `"posts"`.

</details>

<details>
<summary>Hint 3 — What does the model need?</summary>

The Post model needs to broadcast to the `"posts"` channel whenever a record is created/updated/deleted. Look into `broadcasts_to` — but be careful, if you pass a symbol it will broadcast to a per-record channel instead.

</details>

<details>
<summary>Hint 4 — Lambda vs Symbol</summary>

Use `broadcasts_to ->(post) { "posts" }` not `broadcasts_to :posts`.

- **Lambda** `->(_post) { "posts" }` — always broadcasts to a fixed channel called `"posts"`. Every post goes to the same channel. Perfect for an index page.
- **Symbol** `broadcasts_to :author` — broadcasts to the channel of an association, e.g., `author_1`, `author_2`. Each record goes to a different channel. Not what we want here.

</details>

---

## Checkpoints

### Checkpoint 1 — Does it work?

Open 2 tabs on the index → create a post in tab A → does the new post appear in tab B instantly?

If yes, you pass!

### Checkpoint 2 — Can you explain it?

What's the difference between `broadcasts_to ->(post) { "posts" }` and `broadcasts_to :something`?

**Answer:** The lambda returns a fixed string as the channel name — every post broadcasts to the same channel. This is ideal when you want everyone viewing the index to see changes. The symbol calls an association and creates a channel based on that record, e.g., `broadcasts_to :author` broadcasts to each author's individual channel. That's useful when you only want people viewing a specific author's page to see updates.

---

## Next: Branch `13-stimulus`

Turbo handles real-time for us. But is there ANY JavaScript you actually need to write?
