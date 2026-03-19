---
role: mentor
step: 12-turbo-deep-dive
teaching_goal: "Kill the 'magic' fear for Turbo. Students see exactly what happens."
---

# Mentor Guide — Turbo Deep Dive

## Timing

| Block | Minutes | Focus |
|-------|---------|-------|
| DevTools exercise | 5 min | Students open Network tab, click Edit, see the full HTML response, see Turbo extract the matching frame |
| broadcasts explanation | 5 min | Walk through what `broadcasts_to` registers, what goes over the WebSocket, show the WS tab |
| Full picture | 5 min | Draw Turbo Drive vs Frames vs Streams, land the "HTML over the wire" aha moment |

## Key Facilitation

**Have students open DevTools THEMSELVES.** Do not just show them on the projector. Every student should:
- Open Network tab
- Click Edit on a draft post
- See the request and response with their own eyes
- See that the response is a full HTML page
- Understand that Turbo extracts only the matching `<turbo-frame>`

The same applies to the WebSocket exercise. Two tabs open, post a comment, watch the WS message appear. If they see it themselves, they believe it.

## If students seem lost on the full picture

Draw it on a whiteboard:

```
Turbo Drive:
  User clicks link → Turbo intercepts → fetches full HTML → replaces <body>

Turbo Frames:
  User clicks inside frame → Turbo intercepts → fetches HTML → finds matching <turbo-frame id="X"> → swaps only that frame

Turbo Streams (response):
  Form submit → server responds with .turbo_stream → browser reads action + target → appends/replaces/removes

Turbo Streams (broadcast):
  AR callback fires → renders partial → wraps in <turbo-stream> → pushes via WebSocket → all subscribers update
```

The key insight: **all of these are just HTML being sent from server to browser.** No JSON. No client-side JS rendering. The server decides what HTML to send, and the browser puts it where it belongs.

## Checkpoints with Expected Answers

### Checkpoint 1
**Q:** What do all non-GET requests go through?

**A:** Turbo. Every POST, PATCH, DELETE is automatically intercepted by Turbo Drive. Forms do not trigger full page reloads — Turbo handles the request and processes the response.

### Checkpoint 2
**Q:** If the turbo-frame ID on the show page does not match the ID on the edit page, what happens?

**A:** The content disappears. Turbo searches the response for a `<turbo-frame>` with a matching ID. If it cannot find one, it replaces the existing frame with empty content. No error is shown — it fails silently.

### Checkpoint 3
**Q:** What callbacks does `broadcasts_to` register? What does it push over WebSocket?

**A:** It registers `after_create` and `after_destroy` callbacks. On create, it renders the model's partial, wraps it in a `<turbo-stream action="append" target="...">` tag, and pushes that HTML fragment over the Action Cable WebSocket. On destroy, it pushes a `<turbo-stream action="remove" target="...">` — no partial rendering needed.

### Checkpoint 4
**Q:** What is the difference between Turbo Frames and Turbo Streams?

**A:** Turbo Frames intercept navigation within a bounded box and swap content by matching frame IDs. Turbo Streams are explicit instructions from the server (append, replace, remove, etc.) targeting any DOM element by ID — no frame matching needed. Frames are for scoped navigation. Streams are for fine-grained updates, including real-time broadcasts via WebSocket.

## Common Misconceptions

- **"Turbo sends JSON"** — No. It sends HTML. Always HTML. Show them the Network tab to prove it.
- **"broadcasts_to uses polling"** — No. It uses WebSocket (Action Cable). The server pushes to the client. Show the WS tab.
- **"You need to write JavaScript for this"** — No. Zero JS was written. Turbo and Stimulus are the JS — you configure them with HTML attributes.
