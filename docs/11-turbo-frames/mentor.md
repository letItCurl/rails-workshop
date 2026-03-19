---
role: mentor
step: 11-turbo-frames
title: "Turbo Frames — Inline Editing"
day: 2
time: "10:00–11:00"
duration: 60min
difficulty: "\U0001F534 Challenge"
aha_moment: "Inline editing with HTML attributes — zero JavaScript"
driving_force: "'I still need React' — disproven"
---

# Mentor Guide: Turbo Frames — Inline Editing

## Teaching Goal

Students see that Rails handles interactive UI without JavaScript. By the end of this step, the "I still need React for anything interactive" assumption should be broken. They will implement inline editing of draft posts using only `turbo_frame_tag` — no JS, no fetch, no state management.

**THIS IS HARD.** Budget extra time. Students who have only known React/Next will find the mental model unfamiliar. The concept is simple but the debugging is not.

---

## Timing

| Phase | Duration | What Happens |
|-------|----------|--------------|
| Concept | 10 min | Explain what a Turbo Frame is, how matching IDs work, the request/response cycle |
| Hands-on | 35 min | Students implement inline editing on their draft posts |
| Debugging + Checkpoints | 15 min | Walk through checkpoints, help stuck students, common errors |

**Be flexible.** If most students are stuck at the 35-minute mark, extend hands-on time and use checkpoints as debugging sessions rather than quizzes.

---

## CRITICAL: Students WILL Struggle

This is the hardest step in the workshop. Expect it.

The most common issue is **mismatched frame IDs**. When it doesn't work, students see no error — just nothing happening. This is deeply frustrating for developers used to console errors and stack traces.

**Be patient. Guide with questions, not answers.**

- "What ID does `turbo_frame_tag @post` generate?"
- "Open DevTools — what do you see in the Network tab?"
- "Is your Edit link inside or outside the frame?"

Don't jump to the solution. Let them find it. The struggle is where the learning happens.

---

## Checkpoints with Expected Answers

### Checkpoint 1 (green) — After Step 2

**Question:** What HTML does `turbo_frame_tag @post` generate? Which attribute makes it work?

**Expected answer:** It generates `<turbo-frame id="post_42">...</turbo-frame>`. The `id` attribute is what Turbo uses to match frames between the source page and the target page. When Turbo fetches a new page, it looks for a `<turbo-frame>` with the same `id` and swaps the content.

**If they can't answer:** Have them inspect the element in DevTools. The tag is right there in the DOM.

### Checkpoint 2 (yellow) — After Step 4

**Question:** What happens if the frame ID in show doesn't match the frame ID in edit?

**Expected answer:** Turbo fetches the edit page, looks for a `<turbo-frame>` with the matching ID, doesn't find it, and either does nothing or the frame content disappears. No error is shown — it just silently fails.

**If they can't answer:** Have them deliberately break it. Change edit to use `turbo_frame_tag "wrong_id"` and observe.

### Checkpoint 3 (red) — End of step

**Question:** How many lines of JavaScript would you need to build this same inline editing in React?

**Expected answer:** They should think through: at least 1-2 useState hooks (edit mode toggle, form data), a fetch call for the API, conditional rendering logic, form handling, error states. Probably 40-80 lines of JS minimum. Here they added an HTML tag in 2 files — zero JS.

**Driving point home:** This is not a toy example. This is production-ready inline editing. Turbo is what Basecamp, HEY, and Shopify use in production.

---

## Common Errors Table

| Symptom | Cause | Fix |
|---------|-------|-----|
| Clicking Edit causes full page reload | Edit link is outside the `turbo_frame_tag` block | Move the link inside the frame |
| Clicking Edit causes full page reload | Frame IDs don't match between show and edit | Use `turbo_frame_tag @post` in both (not hardcoded strings) |
| Form doesn't appear after clicking Edit | edit.html.erb doesn't have a `turbo_frame_tag` | Add `turbo_frame_tag @post` wrapping the form in edit.html.erb |
| Form doesn't appear after clicking Edit | Frame ID in edit is different from show | Ensure both use `turbo_frame_tag @post` — inspect the generated HTML |
| Submit doesn't update content / frame gets stuck | Controller uses `render :show` instead of `redirect_to @post` | Change controller to `redirect_to @post` after successful update |
| Cancel link does full page navigation | Cancel link is outside the `turbo_frame_tag` block | Move the Cancel link inside the frame |
| Content outside the frame disappears | The frame wraps too much of the page | Wrap only the editable content, keep comments/tags/author outside |
| `<turbo-frame>` tag not rendered at all | Missing `turbo-rails` gem or Turbo not imported | Check Gemfile for `turbo-rails` and `application.js` for Turbo import |
| Student can edit published posts | Missing authorization check | Ensure Edit link only shows for `@post.draft? && @post.user == current_user` |
| Frame loads but shows "Content missing" | The target page returned HTML without a matching `<turbo-frame>` | Check the Network tab response — the edit page must contain a frame with the exact same ID |

---

## If Everything Goes Wrong

Some students may get completely lost. Here's the nuclear option:

**Show the minimal working example.** It's just 2 additions:

1. In `show.html.erb`: wrap content with `<%= turbo_frame_tag @post do %>...<% end %>`
2. In `edit.html.erb`: wrap form with `<%= turbo_frame_tag @post do %>...<% end %>`

That's it. Get this basic case working first. Once clicks swap the frame, THEN add:
- The Edit link inside the frame
- The Cancel link inside the edit frame
- Authorization checks for draft-only editing
- Styling

Build up in layers. Don't try to do everything at once.

---

## Signals to Watch For

- **Frustrated silence:** A student staring at the screen with nothing happening. Go check their frame IDs.
- **"It just reloads the whole page":** Link is outside the frame or Turbo isn't loaded. Quick DevTools check.
- **"I think I need JavaScript for this":** This is the moment to reinforce the aha. They don't. Guide them back to the HTML.
- **Students helping each other debug:** Excellent. Let it happen. Frame ID mismatches are best found by a second pair of eyes.

---

## Key Reminders

- This is Day 2, first step. Students might be rusty from overnight. Give a quick warm-up recap.
- Business rule: only draft posts are editable. Published posts and comments are never inline-edited.
- The controller doesn't need changes for basic Turbo Frame behavior — it's all in the views.
- Don't introduce `data-turbo-frame` or frame targeting yet. Keep it simple: matching IDs only.
