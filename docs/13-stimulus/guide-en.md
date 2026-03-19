---
branch: 13-stimulus
title: "Stimulus — The JS You Actually Need"
lang: en
pair: guide-th.md
day: 2
time: "13:15–13:45"
duration: 30min
difficulty: "\U0001F7E1 Recipe + Why"
prerequisite: 12-turbo-challenge
next: 14-hackathon
rails_guide: https://guides.rubyonrails.org/working_with_javascript_in_rails.html
aha_moment: "The JS you actually need to write is this small — small, scoped, HTML-driven"
business_rule: "No new business rules — adding interactive behaviors"
---

# Stimulus — The JS You Actually Need

## Turbo handles everything… so what about JavaScript?

Turbo handled navigation and real-time for us. So where does JavaScript come in? When do you actually need to write it?

The answer: rarely — and Stimulus makes sure you only write what's necessary.

Think about it. Since this morning we built inline editing with Turbo Frames and real-time updates with Turbo Streams — zero lines of JavaScript. But there are small behaviors that Turbo can't handle: counting characters, toggling elements, auto-dismissing notifications. That's where Stimulus steps in.

---

## What is Stimulus?

Stimulus is a framework for **small JavaScript behaviors**. Emphasis on small.

- It is NOT an SPA framework.
- It does NOT replace React.
- It adds small bits of interactivity to HTML that the server already rendered.

There are 3 core concepts:

| Concept | What it is | Example |
|---------|-----------|---------|
| **Controller** | A JS class bound to a DOM element | `character_counter_controller.js` |
| **Target** | A reference to a DOM element inside the controller | `data-character-counter-target="input"` |
| **Action** | An event that triggers a method on the controller | `data-action="input->character-counter#countCharacters"` |

Just these 3 things. Controller, Target, Action — easy to remember.

---

## Build 1 — Character Counter

We'll build a controller that counts characters in the comment form.

### Generate the controller

```bash
rails g stimulus character_counter
```

### Open the generated file

Open `app/javascript/controllers/character_counter_controller.js` and edit it:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.updateCount()
  }

  countCharacters() {
    this.updateCount()
  }

  updateCount() {
    const length = this.inputTarget.value.length
    this.countTarget.textContent = `${length} characters`
  }
}
```

### Wire it into the comment form

In the view with the comment textarea, add the data attributes:

```erb
<div data-controller="character-counter">
  <%= form.text_area :body,
    data: {
      character_counter_target: "input",
      action: "input->character-counter#countCharacters"
    } %>
  <span data-character-counter-target="count">0 characters</span>
</div>
```

### Test it

Type in the comment box — the character count updates live.

Notice: no `querySelector`, no `addEventListener`, no manual lifecycle management. Stimulus handles all of it.

---

## Build 2 — Toggle Comments

Build a controller that hides and shows the comments section.

### Generate the controller

```bash
rails g stimulus toggle
```

### Write the controller

Open `app/javascript/controllers/toggle_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

### Wire it into the show page

```erb
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">
    Hide/Show Comments
  </button>

  <div data-toggle-target="content">
    <%# comments section here %>
  </div>
</div>
```

### Test it

Click the button — comments disappear. Click again — they come back.

Dead simple. The controller is 5 lines and you get a fully working toggle.

---

## Checkpoint 1 (Green)

**What are the 3 core Stimulus concepts?**

Pause and think before reading on.

> Controller, Target, Action

---

## Checkpoint 2 (Yellow)

**How does `data-action="input->character-counter#countCharacters"` work? Break down each part.**

Pause and think before reading on.

> - `input` — the event being listened to (when the user types)
> - `character-counter` — the controller name (kebab-case)
> - `countCharacters` — the method to call

The pattern is: **event -> controller#method**

---

## THE REVEAL — Stimulus Has Been in the App All Along!

Now open these files:

### `app/javascript/controllers/notification_controller.js`

The flash message that auto-dismisses after 3 seconds? That's Stimulus!

### `app/javascript/controllers/confirm_controller.js`

The custom delete confirmation modal? That's Stimulus too!

### `app/javascript/application.js`

The Turbo confirm override uses Stimulus!

**You've been using Stimulus since Day 2 started — without knowing it.**

Read `notification_controller.js` line by line. You'll see it's the exact same pattern as the character counter and toggle you just built: Controller, Target, Action.

---

## Checkpoint 3 (Red)

**Look at `notification_controller.js` — what does it do? What is `connect()`? What does `setTimeout` do?**

Read the actual code before reading on.

> - `connect()` is called automatically when the controller is attached to a DOM element (like `mounted` in React)
> - `setTimeout` sets a timer to dismiss the flash message after 3 seconds
> - It uses the exact same pattern as the controllers you just wrote!

---

## The Full Hotwire Picture

Now you can see the complete picture:

| Layer | What it does | React equivalent |
|-------|-------------|-----------------|
| **Turbo Drive** | Page navigation without reload | React Router |
| **Turbo Frames** | Partial page updates | Component re-render |
| **Turbo Streams** | Real-time push updates | WebSocket + state management |
| **Stimulus** | Small JS behaviors | Event handlers + useEffect |

These 4 layers together replace 95% of what React does — with far less code.

---

## Self-check

Before moving on, make sure you can:

- [ ] Generate a Stimulus controller with the Rails generator
- [ ] Explain what Controller, Target, and Action are
- [ ] Read a data-action attribute and break down its parts
- [ ] Read an existing controller in the app and understand what it does
- [ ] See how all 4 parts of Hotwire work together

## Next: Hackathon!

Next up we combine everything we've learned — Turbo Drive, Frames, Streams, Stimulus — and build a new feature on your own!
