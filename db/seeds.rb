# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.__elasticsearch__.delete_index! if User.__elasticsearch__.index_exists?
User.__elasticsearch__.create_index!

LogEntry.__elasticsearch__.delete_index! if LogEntry.__elasticsearch__.index_exists?
LogEntry.__elasticsearch__.create_index!


user_count = 50 # 500_000
user_count.times do |i|
  puts "#{user_count-i}" if (i % 100 == 0)

  quote_type = rand(3)

  quote = case quote_type
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
    name: [Faker::Name.first_name, Faker::Name.last_name].join(' '),
    email: Faker::Internet.email,
    quote: quote,
    quote_type: quote_type
  )
end
