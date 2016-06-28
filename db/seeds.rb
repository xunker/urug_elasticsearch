# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user_count = 1_000
user_count.times do |i|
  puts "#{user_count-i}" if (i % 100 == 0)
   
  user_type = rand(3)

  quote = case user_type
    when 0
      Faker::Hacker.say_something_smart
    when 1
      Faker::StarWars.quote
    when 2
      Faker::Hipster.sentences(1).first
    else
      Faker::ChuckNorris.fact
    end

  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    quote: quote,
    user_type: user_type
  )
end