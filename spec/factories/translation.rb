FactoryBot.define do
  factory :translation do
    locale        { 'de-de' }
    source        { 'date' }
    target        { 'dd/mm/yyyy' }
    created_by_id { 1 }
    updated_by_id { 1 }
  end
end
