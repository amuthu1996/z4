require 'rails_helper'

RSpec.describe 'Public Knowledge Base for guest search', type: :system, authenticated: false, searchindex: true do
  include_context 'basic Knowledge Base'

  before do
    configure_elasticsearch(required: true, rebuild: true) do
      published_answer && draft_answer && internal_answer
    end

    visit help_no_locale_path
  end

  it 'shows no results notification for gibberish search' do
    find('.js-search-input').fill_in with: 'Asdasdasdasdasd'
    expect(page).to have_text 'No results were found'
  end

  it 'list published article' do
    expect(page).to allow_to_search_for published_answer
  end

  it 'not list draft article' do
    expect(page).not_to allow_to_search_for draft_answer
  end

  it 'not list internal article' do
    expect(page).not_to allow_to_search_for internal_answer
  end
end
