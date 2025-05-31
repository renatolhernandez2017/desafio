FactoryBot.define do
  factory :message do
    content { "Mensagem de teste" }
    association :user
  end
end
