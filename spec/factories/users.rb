FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:username) { |n| "Username#{n}" }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    sequence(:password) { |n| "Password#{n}A1b2c3XyZqWvRtLpK" }
    password_confirmation { |user| user.password }
    confirmed_at { Time.now } # para Devise confirmable
  end
end
