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
