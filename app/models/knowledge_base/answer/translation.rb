# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/
class KnowledgeBase::Answer::Translation < ApplicationModel
  include HasAgentAllowedParams
  include HasLinks
  include HasSearchIndexBackend
  include KnowledgeBase::Search
  include KnowledgeBase::HasUniqueTitle

  AGENT_ALLOWED_ATTRIBUTES       = %i[title kb_locale_id].freeze
  AGENT_ALLOWED_NESTED_RELATIONS = %i[content].freeze

  belongs_to :kb_locale,  class_name: 'KnowledgeBase::Locale', inverse_of: :answer_translations
  belongs_to :answer,     class_name: 'KnowledgeBase::Answer', inverse_of: :translations, touch: true
  #belongs_to :updated_by, class_name: 'User', inverse_of: :answer_translations

  belongs_to                    :content, class_name: 'KnowledgeBase::Answer::Translation::Content', inverse_of: :translation, dependent: :destroy
  accepts_nested_attributes_for :content, update_only: true

  validates :title,        presence: true,            length: { maximum: 250 }
  validates :content,      presence: true
  validates :kb_locale_id, uniqueness: { scope: :answer_id }

  scope :neighbours_of, ->(translation) { joins(:answer).where(knowledge_base_answers: { category_id: translation.answer&.category_id }) }

  alias assets_essential assets

  def attributes_with_association_ids
    key = "#{self.class}::aws::#{id}"

    cache = Cache.get(key)
    return cache if cache

    attrs = super
    attrs[:linked_references] = linked_references

    Cache.write(key, attrs)

    attrs
  end

  def assets(data = {})
    return data if assets_added_to?(data)

    data = super(data)
    data = Link.reduce_assets(data, linked_references)
    answer.assets(data)
    ApplicationModel::CanAssets.reduce inline_linked_objects, data
  end

  def to_param
    [answer_id, title.parameterize].join('-')
  end

  def search_index_attribute_lookup
    attrs = super

    attrs['title']    = ActionController::Base.helpers.strip_tags attrs['title']
    attrs['content']  = content.search_index_attribute_lookup if content
    attrs['scope_id'] = answer.category_id

    attrs
  end

  def linked_references
    Link.list(link_object: self.class.name, link_object_value: id)
  end

  def inline_linked_objects
    output = []

    scrubber = Loofah::Scrubber.new do |node|
      next if node.name != 'a'
      next if !node.key? 'data-target-type'

      case node['data-target-type']
      when 'knowledge-base-answer'
        if (translation = KnowledgeBase::Answer::Translation.find_by(id: node['data-target-id']))
          output.push translation
        end
      end
    end

    Loofah.scrub_fragment(content.body, scrubber)

    output
  end

  class << self
    def search_preferences(current_user)
      return false if !KnowledgeBase.exists? || !current_user.permissions?('knowledge_base.*')

      {
        prio:                1209,
        direct_search_index: false,
      }
    end

    def search_fallback(query, scope = nil)
      fields = %w[title]
      fields << KnowledgeBase::Answer::Translation::Content.arel_table[:body]

      output = where_or_cis(fields, query)
               .joins(:content)

      if scope.present?
        output = output
                 .joins(:answer)
                 .where(knowledge_base_answers: { category_id: scope })
      end

      output
    end
  end
end
