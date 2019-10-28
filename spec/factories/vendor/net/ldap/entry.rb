FactoryBot.define do

  # add custom attributes via:
  # mocked_entry         = build(:ldap_entry)
  # mocked_entry['attr'] = [value, another_value]
  factory :ldap_entry, class: Net::LDAP::Entry do
    initialize_with { new('dc=com') }
  end
end
