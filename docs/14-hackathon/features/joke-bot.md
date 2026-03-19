---
feature: Joke Bot
difficulty: "\U0001F7E2 Easy"
teaches: Solid Queue, recurring jobs, background processing
---

# Joke Bot

## Business Need

> An automated bot posts a random joke every 30 seconds.

This is the zero-skill, maximum-fun option. A background job creates a new Post with a random joke from a built-in list. Because the index page already has Turbo Streams from previous challenges, everyone in the room watches jokes appear in real-time. This is THE demo feature.

---

## ERD

No new tables needed. The job creates regular `Post` records using the existing schema.

You will need a "bot" user account to own the posts. Create one in seeds or console:
```ruby
User.find_or_create_by!(email: "jokebot@oddlyhonest.com") do |u|
  u.password = "password123"
end
```

---

## Steps

### 1. Generate the job

```bash
rails g job PostJoke
```

### 2. Write the job

**`app/jobs/post_joke_job.rb`**
```ruby
class PostJokeJob < ApplicationJob
  queue_as :default

  JOKES = [
    "The first 5 days after the weekend are the hardest.",
    "I told my wife she was drawing her eyebrows too high. She looked surprised.",
    "Why do programmers prefer dark mode? Because light attracts bugs.",
    "I'm on a seafood diet. I see food and I eat it.",
    "The best time to plant a tree was 20 years ago. The second best time is to close Jira and go outside.",
    "A clean house is the sign of a broken computer.",
    "I don't need a hair stylist. My pillow gives me a new hairstyle every morning.",
    "Nothing ruins a Friday more than realizing it's only Tuesday.",
    "My boss told me to have a good day, so I went home.",
    "I'm not lazy, I'm on energy saving mode.",
    "Experience is what you get when you didn't get what you wanted.",
    "The road to success is always under construction.",
    "If at first you don't succeed, then skydiving is not for you.",
    "I used to think I was indecisive. But now I'm not so sure.",
    "Behind every great man is a woman rolling her eyes.",
    "A meeting is an event where minutes are taken and hours are wasted.",
    "The only thing worse than a meeting is a meeting that could have been an email.",
    "Artificial intelligence is no match for natural stupidity.",
    "There are only 10 types of people: those who understand binary and those who don't.",
    "To err is human. To blame it on someone else shows management potential.",
  ].freeze

  def perform
    bot = User.find_or_create_by!(email: "jokebot@oddlyhonest.com") do |u|
      u.password = "password123"
    end

    Post.create!(
      title: "Joke of the moment",
      body: JOKES.sample,
      user: bot
    )
  end
end
```

### 3. Configure recurring schedule

**`config/recurring.yml`**
```yaml
production:
  post_joke:
    class: PostJokeJob
    schedule: every 30 seconds

development:
  post_joke:
    class: PostJokeJob
    schedule: every 30 seconds
```

> **Note:** Rails 8 with Solid Queue reads this file automatically. No additional configuration needed.

### 4. That's it!

The index page already broadcasts new posts via Turbo Streams (from the earlier challenge). The jokes will appear automatically.

---

## Running It

Start the job runner in a separate terminal:

```bash
bin/jobs
```

Open the posts index page in your browser. Wait 30 seconds. A new joke should appear without refreshing the page.

Open the same page on multiple browsers/phones. Everyone sees the jokes appear at the same time.

---

## Test

**`test/jobs/post_joke_job_test.rb`**
```ruby
require "test_helper"

class PostJokeJobTest < ActiveJob::TestCase
  test "job creates a new post" do
    # Ensure bot user exists
    User.find_or_create_by!(email: "jokebot@oddlyhonest.com") do |u|
      u.password = "password123"
    end

    assert_difference "Post.count", 1 do
      PostJokeJob.perform_now
    end
  end

  test "post is created by the bot user" do
    PostJokeJob.perform_now
    post = Post.last
    assert_equal "jokebot@oddlyhonest.com", post.user.email
  end

  test "post body is one of the known jokes" do
    PostJokeJob.perform_now
    post = Post.last
    assert_includes PostJokeJob::JOKES, post.body
  end
end
```

---

## Demo Tips

This is the best feature to demo last. Have every team open the index page on their laptops. Start `bin/jobs` and watch the room react as jokes appear on all screens simultaneously. It is a great way to end the hackathon.

---

## Hints (use only when stuck)

1. **Hint 1** — Did you run `bin/jobs` in a separate terminal? The recurring schedule only runs when the job runner is active.
2. **Hint 2** — If posts are created but don't appear in real-time, check that Turbo Streams broadcasting is set up on the Post model (from the earlier challenge). You need `broadcasts_to` or `broadcasts` in the Post model.
3. **Hint 3** — If the bot user can't be created, check your User model validations. The `find_or_create_by!` might fail if you have extra required fields.
