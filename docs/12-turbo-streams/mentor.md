---
branch: 12-turbo-streams
role: mentor
day: 2
time: "11:15–12:00"
duration: 45min
difficulty: "\U0001F534 Challenge"
prerequisite: 11-turbo-frames
next: 12-turbo-deep-dive
aha_moment: "Real-time with 2 lines — broadcasts_to + turbo_stream_from"
driving_force: "'I still need React' -> disproven for real-time too"
---

# Mentor Guide: Turbo Streams — Real-time Without JS

## Teaching Goal

Students prove that real-time updates work without writing any JavaScript. This is conceptually simpler than Turbo Frames (just 2 lines), but the "magic" factor is high — let them experience the wow moment before explaining the mechanism.

The driving force here: many students believe real-time features absolutely require a JS framework. This step disproves that assumption definitively.

---

## Timing Breakdown

| Block | Duration | Activity |
|-------|----------|----------|
| Concept | 10 min | Explain Turbo Streams, broadcasts, Action Cable/Solid Cable |
| Hands-on | 25 min | Create partial, update view, add broadcasts_to, test |
| Testing & Checkpoints | 10 min | Two-tab testing, checkpoint questions, if-stuck support |

---

## Concept Phase (10 min)

Start with the question: "You're reading a post. Someone comments. What has to happen for you to see it without refreshing?"

Walk through the architecture briefly:
- Server needs to push to client (WebSocket)
- Client needs to know what to do with the data (Turbo Streams)
- Rails 8 provides both out of the box (Action Cable + Solid Cable, no Redis)

Do NOT deep-dive into Action Cable internals yet — save that for the deep-dive step. Keep it to: "server pushes HTML to browser via WebSocket, browser knows how to insert it."

---

## Hands-on Phase (25 min)

### Step 1: Comment Partial (5 min)

Students create `app/views/comments/_comment.html.erb`. Emphasize:
- The filename **must** match the model name — `broadcasts_to` looks for it automatically
- Wrap in `turbo_frame_tag comment` for consistency with Turbo Frames from the previous step
- Include both content display and delete button

### Step 2: Update Show View (5 min)

Two changes to `app/views/posts/show.html.erb`:
- Add `turbo_stream_from @post` — this is the subscription line
- Switch to `render @post.comments` to use the partial

**Critical**: `turbo_stream_from` must come BEFORE the comments div. If placed after, subscription timing can cause issues.

### Step 3: broadcasts_to (2 min)

One line in `app/models/comment.rb`: `broadcasts_to :post`

Let the simplicity sink in. Don't rush past it.

### Step 4: Two-Tab Testing (13 min)

This is the payoff. Have students:
1. Open the same post in 2 browser tabs (or pair with a neighbor)
2. Comment in one tab, watch the other
3. Delete in one tab, watch the other
4. Try with 3+ tabs if time allows

Let them react to the magic. Then ask: "How many lines of JavaScript did you write?" (Zero.)

---

## Checkpoints

### Checkpoint 1 (Green) — Knowledge Check

**Ask**: What does `broadcasts_to :post` do? What one line subscribes the view?

**Expected**: `broadcasts_to :post` makes Rails broadcast HTML to all viewers of that post on create/destroy. `turbo_stream_from @post` subscribes the browser.

**If they struggle**: Point them back to the model and view. It's literally 2 lines — help them identify which does what.

### Checkpoint 2 (Yellow) — Verification

**Ask**: Open 2 tabs, comment in one. Does it appear in the other? What technology enables this?

**Expected**: Yes, it appears instantly. WebSocket via Action Cable (Solid Cable in Rails 8, backed by the database instead of Redis).

**If it doesn't work**: See Common Errors below.

### Checkpoint 3 (Red) — Comparison

**Ask**: What would you need to set up in React for the same real-time behavior?

**Expected**: WebSocket connection setup, state management for subscription, JSON parsing, component re-rendering logic, cleanup on unmount, reconnection handling. Multiple files, multiple libraries.

**Purpose**: Reinforce the aha moment. Not to bash React, but to appreciate what Rails gives you for free.

---

## Common Errors

### Broadcasts not working at all

**Symptom**: Comment saves but doesn't appear in other tabs.

**Cause**: Action Cable not mounted in routes.

**Fix**: Check `config/routes.rb` has `mount ActionCable.server => '/cable'`. Rails 8 apps should have this by default, but verify.

### Partial not found

**Symptom**: Error when broadcasting — `ActionView::MissingTemplate`.

**Cause**: Partial filename doesn't match model name or is in wrong directory.

**Fix**: Must be `app/views/comments/_comment.html.erb` (plural directory, singular filename with underscore prefix).

### turbo_stream_from not subscribing

**Symptom**: No WebSocket connection visible in browser dev tools Network tab.

**Cause**: `turbo_stream_from @post` placed after the comments div or inside a turbo frame that gets replaced.

**Fix**: Move it before the comments section, outside any turbo frames.

### Comments appear doubled

**Symptom**: When you comment, TWO copies appear in your own tab (but only one in other tabs).

**Cause**: Both the broadcast AND the turbo stream response from the controller create action fire for the submitting user.

**Fix**: In the comments controller create action, respond with `turbo_stream` format that uses `turbo_stream.replace` or handle the duplication. Alternatively, the broadcast can target a different container. This is a known gotcha — help students understand WHY it happens even if the fix is provided.

### Delete doesn't broadcast to other tabs

**Symptom**: Deleting a comment removes it locally but not in other tabs.

**Cause**: Missing `dependent: :destroy` on the association, or the destroy action doesn't trigger model callbacks.

**Fix**: Ensure `has_many :comments, dependent: :destroy` in Post model, and that the controller uses `@comment.destroy` (not `delete`).

---

## Rails 8 Solid Cable Note

Rails 8 uses Solid Cable by default for Action Cable. This means:
- No Redis needed in development or production (for small-to-medium apps)
- Config is in `config/cable.yml` — should already be set to `async` in development and `solid_cable` in production
- It uses the database as a message queue
- Students do NOT need to install or configure anything extra

If students ask about Redis: "Solid Cable works great for most apps. Redis is still an option for high-throughput scenarios, but you won't need it for this workshop."

---

## If Everything Goes Wrong

Fallback plan if time is running out or too many students are stuck:

1. **Show the 2 lines**: Write `broadcasts_to :post` and `turbo_stream_from @post` on the board/screen. Explain what each does.
2. **Get basic create working first**: Focus only on new comments appearing. Ignore delete broadcasting for now.
3. **Provide the partial**: If partial naming is causing issues, just give them the complete `_comment.html.erb` file.
4. **Demo it**: If all else fails, demo the working version from the solution branch. The aha moment still lands even as a demo.

The key takeaway must survive: real-time updates in Rails = 2 lines, zero JavaScript.

---

## Transition to Deep Dive

After testing, tell students: "It works. But you probably have questions. How does the WebSocket connection get established? How does Rails know which partial to render? What does the broadcast message actually look like? We'll dig into all of that after the break."

This creates anticipation for the deep-dive step and gives students something to think about during the break.
