FactoryBot.define do
  factory :object_lookup do
    name { (ApplicationModel.descendants.map(&:name) - ObjectLookup.pluck(:name)).sample }
  end
end
