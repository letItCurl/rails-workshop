---
branch: 09-erd-exercise
title: "ERD Exercise — Model Any Problem"
lang: en
pair: guide-th.md
day: 1
time: "15:50–16:30"
duration: 40min
difficulty: "\U0001F534 Challenge"
prerequisite: 08-team-survival
next: 10-turbo-frames
rails_guide:
  - https://guides.rubyonrails.org/active_record_basics.html
  - https://guides.rubyonrails.org/association_basics.html
aha_moment: "Give me any business problem, I can sketch the ERD — this is the skill AI can't replace"
business_rule: "No new business rules — this step proves you can model anything"
---

# ERD Exercise — Model Any Problem

## Forget the Code for a Moment

Grab a pen and paper.

All day you've been writing code — models, migrations, associations, validations, tests, everything. But the most important skill isn't typing code. It's **understanding a problem and modeling it as a database**.

If you truly understand business → database → code, you can model anything.

---

## Step 1: See the ERD of the OddlyHonest App You Built Today

Generate the ERD for the current app:

```bash
bundle exec rails-erd
```

(or `rails erd` if you have it installed as a binstub)

Open the generated ERD file (usually `erd.pdf` or `erd.png`) and look at the diagram.

**Ask yourself:** Does this diagram match what you built? Can you see all the relationships? Post → Comment, Post ↔ Tag through PostTag, User → Post?

---

## Step 2: 5 Problems, 5 ERDs

For each problem:
- Read the business description
- Draw the ERD on paper, in groups (5 minutes)
- Discuss answers together

---

### Problem 1: Food Delivery

**Business:** A restaurant has many menu items. A customer places an order. Each order has many order items. Each order item references a menu item. Customers have an address for delivery.

**Entities you need:**
- Restaurant
- MenuItem
- Customer
- Order
- OrderItem

**Key question:** "OrderItem is a join table between what and what?"

> OrderItem joins Order and MenuItem — just like PostTag joins Post and Tag. But OrderItem also carries quantity, price.

---

### Problem 2: Hotel Booking

**Business:** A hotel has many rooms. Each room has a type and price. A guest creates a booking for a specific room with check-in and check-out dates.

**Entities you need:**
- Hotel
- Room
- Guest
- Booking

**Key question:** "Booking belongs_to what?"

> Booking belongs_to :guest and belongs_to :room — it's a join table between Guest and Room, but with check_in and check_out dates.

---

### Problem 3: School System

**Business:** A student enrolls in courses. Courses are taught by teachers. Enrollment is a join table that also stores the grade.

**Entities you need:**
- Student
- Course
- Teacher
- Enrollment

**Key question:** "Enrollment as has_many :through — does it look like PostTag?"

> Yes! Student has_many :courses, through: :enrollments is exactly like Post has_many :tags, through: :post_tags. But Enrollment carries a grade field.

---

### Problem 4: E-commerce

**Business:** Products belong to categories. Users add products to a cart through CartItems. Users place orders through OrderItems.

**Entities you need:**
- Product
- Category
- User
- Cart
- CartItem
- Order
- OrderItem

**Key question:** "How are CartItem and OrderItem different? Why separate them?"

> CartItem is "stuff you want" — deletable, editable, unpaid. OrderItem is "stuff you bought" — a historical record that can't be deleted. The price at time of purchase must be frozen.

---

### Problem 5: Social Media Follow System

**Business:** A user can follow another user. Follow is a self-referential join table with follower_id and followed_id.

**Entities you need:**
- User
- Follow

**Key question:** "The Follow table has two user IDs — how does that work?"

> Follow belongs_to :follower, class_name: "User" and belongs_to :followed, class_name: "User" — one table, two foreign keys, both pointing to the same users table.

---

## Step 3: Pick 1 Problem, Build It for Real

Choose your favorite problem and generate the models:

```bash
# Example: if you pick Problem 1 - Food Delivery
rails g model Restaurant name:string
rails g model MenuItem name:string price:decimal restaurant:references
rails g model Customer name:string address:text
rails g model Order customer:references restaurant:references status:string
rails g model OrderItem order:references menu_item:references quantity:integer price:decimal

rails db:migrate
```

Then generate the ERD again:

```bash
bundle exec rails-erd
```

Look at the diagram — does it match what you drew on paper?

---

## Reflection: The Skill AI Can't Replace

In the age of AI, the skill AI cannot replace is **understanding a problem → modeling the database**.

AI can generate code. But AI doesn't know what your business needs. It doesn't know that CartItem and OrderItem must be separate. It doesn't know that Follow needs to be self-referential.

**That's what you just did.**

---

## Day 1 Wrap-up

You started from `rails new` and built a complete app:

- CRUD for Posts
- Comments that belong_to Post
- Authentication with Devise
- Business rules (can't delete posts with comments, can't edit others' posts)
- Tags via many-to-many (PostTag)
- Rich Text with Action Text
- Image uploads with Active Storage
- Full test coverage
- Team collaboration workflow
- ERD modeling for 5 business problems

**All in one day.**

---

## Self-check

- [ ] Generated the ERD for OddlyHonest
- [ ] Drew ERDs for 5 problems on paper
- [ ] Can explain what a join table is and when to use one
- [ ] Can explain a self-referential association
- [ ] Picked 1 problem and generated the models
- [ ] Generated ERD matches the paper drawing

## Day 2 Teaser

Tomorrow we take the app you built and make it **interactive** with Turbo Frames, Stimulus, and Hotwire — updating the page without full reloads. If today was "understand the data," tomorrow is "understand the interaction."
