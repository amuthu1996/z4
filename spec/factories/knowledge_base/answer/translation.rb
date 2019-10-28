FactoryBot.define do
  factory 'knowledge_base/answer/translation', aliases: %i[knowledge_base_answer_translation] do
    answer           { nil }
    kb_locale        { nil }
    sequence(:title) { |n| "#{Faker::Appliance.equipment} ##{n}" }
    content          { build(:knowledge_base_answer_translation_content) }

    before(:create) do |translation, _context|
      if translation.answer.nil?
        build(:knowledge_base_answer, translations: [translation])
      end

      if translation.kb_locale.nil?
        translation.kb_locale = translation.answer.category.knowledge_base.kb_locales.first
      end
    end

    after(:build) do |translation, _context|
      if translation.answer.nil?
        build(:knowledge_base_answer, translations: [translation])
      end

      if translation.kb_locale.nil?
        translation.kb_locale = translation.answer.category.knowledge_base.kb_locales.first
      end
    end
  end
end
