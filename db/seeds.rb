# Faker日本語ロケール設定
Faker::Config.locale = "ja"

puts "Creating users and inquiries..."

10.times do |i|
  user = User.create!(
    name: Faker::Name.name,
    email: "user#{i + 1}@example.com",
    phone: Faker::PhoneNumber.phone_number,
    address: "#{Faker::Address.state}#{Faker::Address.city}#{Faker::Address.street_address}"
  )

  rand(1..3).times do
    user.inquiries.create!(
      subject: Faker::Lorem.sentence(word_count: 3),
      body: Faker::Lorem.paragraph(sentence_count: 3)
    )
  end
end

puts "Created #{User.count} users and #{Inquiry.count} inquiries."
