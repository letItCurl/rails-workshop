---
branch: 12-turbo-streams
type: progress
day: 2
time: "11:15–12:00"
---

# Progress: Turbo Streams

## Student Name: _______________

## Checkpoints

### Checkpoint 1 (Green) — Knowledge Check
- [ ] Can explain what `broadcasts_to :post` does
- [ ] Can identify the one line needed in the view (`turbo_stream_from @post`)

### Checkpoint 2 (Yellow) — Verification
- [ ] Opened 2 browser tabs on the same post
- [ ] New comment in tab A appears in tab B instantly
- [ ] Deleted comment in tab A disappears from tab B
- [ ] Can name the technology (WebSocket via Action Cable / Solid Cable)

### Checkpoint 3 (Red) — Comparison
- [ ] Can describe what React would require for equivalent real-time behavior
- [ ] Understands the difference in complexity

## Implementation Checklist

- [ ] Created `app/views/comments/_comment.html.erb` partial
- [ ] Added `turbo_stream_from @post` to show view (before comments div)
- [ ] Changed comments rendering to use `render @post.comments`
- [ ] Added `broadcasts_to :post` in Comment model
- [ ] Tested real-time create in multiple tabs
- [ ] Tested real-time delete in multiple tabs

## Stuck Points

_Record where you got stuck and how you resolved it. This helps mentors identify common issues._

| Time | What I was stuck on | How it was resolved |
|------|---------------------|---------------------|
|      |                     |                     |
|      |                     |                     |
|      |                     |                     |

## Common Issues Reference

- **Broadcasts not working**: Check `mount ActionCable.server => '/cable'` in routes
- **Partial not found**: Filename must be `_comment.html.erb` in `app/views/comments/`
- **Not subscribing**: `turbo_stream_from @post` must be BEFORE the comments div
- **Comment appears twice**: Both broadcast and controller response fire — needs handling
- **Delete not broadcasting**: Check `dependent: :destroy` and use `destroy` not `delete`

## Notes

_Space for personal notes, questions for the deep dive, or observations._

---

## Self-Assessment

After completing this step:

- [ ] I understand how Turbo Streams enable real-time updates
- [ ] I can set up broadcasting with `broadcasts_to`
- [ ] I can subscribe a view with `turbo_stream_from`
- [ ] I have questions about HOW it works internally (good — that's next!)
