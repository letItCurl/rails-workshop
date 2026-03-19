---
role: mentor
step: 13-stimulus
title: "Mentor Guide — Stimulus"
day: 2
time: "13:15–13:45"
duration: 30min
teaching_goal: "Students see that the JS they actually need is small, scoped, and HTML-driven. The reveal of existing controllers is the aha moment."
---

# Mentor Guide — Stimulus

## Teaching Goal

Students should walk away understanding that the JavaScript they actually need to write in a Hotwire app is **small, scoped, and HTML-driven**. The big aha moment is the reveal that they've been using Stimulus controllers all along.

---

## Timing Breakdown

| Block | Duration | What happens |
|-------|----------|-------------|
| Concept intro | 5 min | Controller / Target / Action — keep it brief |
| Build: Character Counter | 10 min | Guided live-coding, students follow along |
| Build: Toggle Comments | 10 min | Students build with less hand-holding |
| The Reveal + Existing Controllers | 5 min | The key teaching moment |

**Total: 30 minutes**

---

## Checkpoints

### Checkpoint 1 (Green) — After concept intro

**Question:** What are the 3 core Stimulus concepts?

**Expected answer:** Controller, Target, Action

**If students struggle:** Draw it on the whiteboard. Controller is the box, Targets are elements inside the box, Actions are arrows from events to methods.

### Checkpoint 2 (Yellow) — After character counter

**Question:** How does `data-action="input->character-counter#countCharacters"` work? Break it down.

**Expected answer:**
- `input` — the DOM event
- `character-counter` — the controller name (kebab-case)
- `countCharacters` — the method on the controller

**If students struggle:** Write the pattern on the board: `event -> controller#method`. Have them identify each part.

### Checkpoint 3 (Red) — After the reveal

**Question:** Look at `notification_controller.js` — what does it do? What is `connect()`? What does `setTimeout` do?

**Expected answer:**
- `connect()` runs automatically when the controller attaches to the DOM
- `setTimeout` auto-dismisses the flash notification after 3 seconds
- It follows the same Controller/Target/Action pattern they just learned

**If students struggle:** Have them compare side-by-side with the character counter controller. Point out the structural similarities: import, class, targets, connect, methods.

---

## Common Errors

### Controller name mismatch
**Symptom:** Controller doesn't connect, nothing happens.
**Cause:** The HTML uses kebab-case (`character-counter`) but students write the filename or class differently.
**Fix:** Remind them: filename uses underscores (`character_counter_controller.js`), HTML uses kebab-case (`data-controller="character-counter"`), the JS class is auto-mapped. The generator handles the filename — just make sure the HTML matches.

### Target not found
**Symptom:** `Error: Missing target element "input" for "character-counter" controller`
**Cause:** Wrong `data-*-target` attribute name, or the target element is outside the controller's DOM scope.
**Fix:** Check that (1) the target attribute exactly matches what's in `static targets`, (2) the target element is a descendant of the element with `data-controller`.

### Action not firing
**Symptom:** Controller connects but the method never runs.
**Cause:** Wrong event name in `data-action`. Common mistake: using `change` instead of `input` for live typing, or forgetting the event entirely.
**Fix:** Remind students the format is `event->controller#method`. For textarea live updates, the event must be `input`, not `change` (which only fires on blur).

---

## KEY TEACHING MOMENT: The Reveal

This is the most important 5 minutes of the session. Do not rush it.

**"คุณใช้ Stimulus มาตั้งแต่เช้า"** — let that sink in.

Steps:
1. Ask: "Remember the flash notifications that auto-dismiss? And the custom delete confirmation modal? How do you think those work?"
2. Let students guess.
3. Open `app/javascript/controllers/notification_controller.js` on the projector.
4. Let them read it. Wait. Don't explain immediately.
5. Ask: "Does this look familiar? What pattern do you see?"
6. They should recognize Controller, Target, Action — the same pattern they just built twice.
7. Then open `app/javascript/controllers/confirm_controller.js` — same thing.
8. Reinforce: "You've been using Stimulus since Day 2 started. You just didn't know it had a name."

This moment drives home the point: Stimulus is so lightweight and HTML-driven that you can use it without even realizing it. That's the design goal.

---

## The Full Picture

After the reveal, quickly sketch the Hotwire stack on the board:

```
Turbo Drive    — page navigation
Turbo Frames   — partial updates
Turbo Streams  — real-time push
Stimulus       — small JS behaviors
```

Ask: "What does this replace?" (Answer: most of what you'd use React for)

This sets up the hackathon nicely — they now have all 4 tools in their belt.

---

## Tips

- Let the character counter build be fully guided — it's their first Stimulus controller.
- For the toggle build, give them the requirements and let them try before showing the solution. It's a confidence builder.
- The reveal is emotional, not technical. Don't over-explain. Let them feel the "oh!" moment.
- If time is tight, cut the toggle build short and prioritize the reveal. The reveal is more valuable.
