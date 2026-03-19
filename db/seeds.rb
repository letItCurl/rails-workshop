# Seed data for OddlyHonest workshop
# Run: rails db:seed

puts "Seeding posts..."

[
  { title: "The truth about deadlines", body: "They're always made up. Every single one." },
  { title: "Why meetings could be emails", body: "Because they could. You know it. I know it." },
  { title: "Start simple, evolve forever", body: "The best code is the code you didn't write." }
].each do |attrs|
  Post.find_or_create_by!(title: attrs[:title]) do |post|
    post.body = attrs[:body]
  end
end

puts "Seeded #{Post.count} posts."

puts "Seeding tags..."

%w[Ruby Rails Database Testing Hotwire].each do |name|
  Tag.find_or_create_by!(name: name)
end

puts "Seeded #{Tag.count} tags."

# Create a demo user for seeded content
puts "Seeding demo user..."
demo_user = User.find_or_create_by!(email: "demo@oddlyhonest.com") do |user|
  user.password = "password"
end

# Assign demo user to existing posts without a user
Post.where(user_id: nil).update_all(user_id: demo_user.id)
puts "Demo user: demo@oddlyhonest.com / password"
