---
role: mentor
step: 09-erd-exercise
day: 1
time: "15:50–16:30"
duration: 40min
aha_moment: "Give me any business, I'll sketch the ERD"
driving_force: "Model any problem as ERD — the transferable superpower"
---

# Mentor Guide: ERD Exercise

## Teaching Goal

Prove that the skill transfers beyond Rails. Students have spent all day building one app. Now they prove they can model **anything** — not just OddlyHonest, but food delivery, hotels, schools, e-commerce, social media.

This is the "one kick" payoff. The skill is: business problem → ERD → database → code.

---

## Timing Breakdown (40 minutes)

| Time | Activity | Duration |
|------|----------|----------|
| 15:50–15:55 | Setup + generate rails-erd for OddlyHonest | 5 min |
| 15:55–16:20 | 5 problems, 5 min each (draw + discuss) | 25 min |
| 16:20–16:30 | Pick one problem, generate models, generate ERD | 10 min |

---

## Setup (5 min)

Make sure `rails-erd` gem is in the Gemfile (group :development). If not:

```ruby
gem 'rails-erd', group: :development
```

```bash
bundle install
bundle exec rails-erd
```

Show the generated diagram on screen. Walk through it quickly: "This is everything you built today."

---

## Expected ERD Answers

### Problem 1: Food Delivery

```
Restaurant ──< MenuItem
Customer ──< Order
Order ──< OrderItem >── MenuItem
```

- **Entities:** Restaurant, MenuItem, Customer, Order, OrderItem
- **Join table:** OrderItem (joins Order + MenuItem)
- **Key relationships:**
  - Restaurant has_many :menu_items
  - Customer has_many :orders
  - Order has_many :order_items
  - Order belongs_to :customer
  - OrderItem belongs_to :order, belongs_to :menu_item
- **Extra fields on join:** quantity, price (frozen at time of order)

### Problem 2: Hotel Booking

```
Hotel ──< Room
Guest ──< Booking >── Room
```

- **Entities:** Hotel, Room, Guest, Booking
- **Join table:** Booking (joins Guest + Room)
- **Key relationships:**
  - Hotel has_many :rooms
  - Room belongs_to :hotel
  - Guest has_many :bookings
  - Booking belongs_to :guest, belongs_to :room
- **Extra fields on join:** check_in, check_out, status

### Problem 3: School System

```
Teacher ──< Course
Student ──< Enrollment >── Course
```

- **Entities:** Student, Course, Teacher, Enrollment
- **Join table:** Enrollment (joins Student + Course)
- **Key relationships:**
  - Teacher has_many :courses
  - Course belongs_to :teacher
  - Student has_many :enrollments
  - Student has_many :courses, through: :enrollments
  - Enrollment belongs_to :student, belongs_to :course
- **Extra fields on join:** grade
- **Direct parallel to PostTag** — this is the one students should recognize immediately

### Problem 4: E-commerce

```
Category ──< Product
User ──< Cart ──< CartItem >── Product
User ──< Order ──< OrderItem >── Product
```

- **Entities:** Product, Category, User, Cart, CartItem, Order, OrderItem
- **Join tables:** CartItem (joins Cart + Product), OrderItem (joins Order + Product)
- **Key relationships:**
  - Category has_many :products
  - User has_one :cart (or has_many :carts)
  - Cart has_many :cart_items
  - CartItem belongs_to :cart, belongs_to :product
  - User has_many :orders
  - Order has_many :order_items
  - OrderItem belongs_to :order, belongs_to :product
- **Key insight:** CartItem is mutable (change quantity, remove items). OrderItem is immutable (historical record with frozen price).

### Problem 5: Social Media Follow System

```
User ──< Follow (as follower)
User ──< Follow (as followed)
```

- **Entities:** User, Follow
- **Join table:** Follow (self-referential, joins User to User)
- **Key relationships:**
  - User has_many :follows_as_follower, class_name: "Follow", foreign_key: :follower_id
  - User has_many :follows_as_followed, class_name: "Follow", foreign_key: :followed_id
  - User has_many :following, through: :follows_as_follower, source: :followed
  - User has_many :followers, through: :follows_as_followed, source: :follower
  - Follow belongs_to :follower, class_name: "User"
  - Follow belongs_to :followed, class_name: "User"
- **This is the hardest one.** Self-referential associations are a new concept. Give extra time if needed.

---

## Key Facilitation Notes

**Let groups struggle.** Do not give answers immediately. Ask guiding questions:

- "What belongs_to what?"
- "Where's the join table?"
- "What can't exist without what?"
- "Is this a has_many or a belongs_to?"
- "Does this remind you of something we built today?"

**Watch for these common mistakes:**
- Forgetting the join table (trying to put multiple foreign keys on one model)
- Not recognizing that OrderItem/CartItem/Enrollment ARE join tables
- Confusion about which side has the foreign key (belongs_to = has the FK)
- On Problem 5: trying to use a single `user_id` column instead of two separate FKs

**Celebrate correct answers loudly.** This is the end of Day 1. Students should feel accomplished.

---

## If Time Is Short

Do problems **1, 3, and 5 only**. They cover the full range:

- **Problem 1 (Food Delivery):** Basic associations + join table with extra data
- **Problem 3 (School System):** Direct has_many :through parallel to what they built
- **Problem 5 (Follow System):** Self-referential — the new concept

Skip 2 (Hotel) and 4 (E-commerce) as they are variations of patterns already covered.

---

## Day 1 Closing

End with energy. Recap what they built:

"You started with nothing. Now you have a full app with auth, business rules, tags, rich text, images, and tests. And you just proved you can model ANY business problem. Tomorrow we make it interactive."

Make sure students commit and push their work before leaving.
