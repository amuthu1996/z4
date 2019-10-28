require 'rails_helper'

RSpec.describe 'Public Knowledge Base for guest', type: :system, authenticated: false do
  include_context 'basic Knowledge Base'

  before do
    published_answer && draft_answer && internal_answer
  end

  context 'homepage' do
    before { visit help_no_locale_path }

    it('is redirected to primary locale') { expect(page).to have_current_path help_root_path(primary_locale.system_locale.locale) }

    it { expect(page).not_to have_selector(:breadcrumb) }
    it { expect(page).not_to have_selector(:knowledge_base_editor_bar) }

    it 'shows category' do
      within '.main' do
        expect(page).to have_selector(:link_containing, published_answer.category.translation.title)
      end
    end

    it 'does not show answer' do
      within '.main' do
        expect(page).not_to have_selector(:link_containing, published_answer.translation.title)
      end
    end
  end

  context 'category' do
    before { visit help_category_path(primary_locale.system_locale.locale, category) }

    it { expect(page).to have_selector(:breadcrumb) }

    it 'shows published answer' do
      within '.main' do
        expect(page).to have_selector(:link_containing, published_answer.translation.title)
      end
    end

    it 'does not show draft answer' do
      within '.main' do
        expect(page).not_to have_selector(:link_containing, draft_answer.translation.title)
      end
    end

    it 'does not show internal answer' do
      within '.main' do
        expect(page).not_to have_selector(:link_containing, internal_answer.translation.title)
      end
    end

    context 'breadcrumb' do
      it { expect(page).to have_selector(:breadcrumb, count: 2) }
      it { expect(page.all(:breadcrumb)[0]).to have_text(knowledge_base.translation.title) }
      it { expect(page.all(:breadcrumb)[1]).to have_text(category.translation.title) }
    end
  end

  context 'answer' do
    before { visit help_answer_path(primary_locale.system_locale.locale, category, published_answer) }

    context 'breadcrumb' do
      it { expect(page).to have_selector(:breadcrumb, count: 3) }
      it { expect(page.all(:breadcrumb)[0]).to have_text(knowledge_base.translation.title) }
      it { expect(page.all(:breadcrumb)[1]).to have_text(category.translation.title) }
      it { expect(page.all(:breadcrumb)[2]).to have_text(published_answer.translation.title) }
    end
  end

  context 'wrong locale' do
    before { visit help_root_path(alternative_locale.system_locale.locale) }

    it { expect(page).to have_selector(:knowledge_base_language_banner) }

    context 'switch to correct locale after clicking on language banner' do
      before do
        within '.language-banner' do
          click_on 'activate'
        end
      end

      it { expect(page).not_to have_selector(:knowledge_base_language_banner) }
    end
  end

  context 'offer in another locale' do
    before do
      create(:knowledge_base_translation, kb_locale: alternative_locale)
      visit help_answer_path(alternative_locale.system_locale.locale, category, published_answer)
    end

    it { expect(page).to have_text(published_answer.translation_primary.title) }
    it { expect(page).to have_text('only available in these languages') }
    it { expect(page).not_to have_selector('h1', text: published_answer.translation_primary.title) }

    context 'follow primary locale' do
      before { click_on published_answer.translation_primary.title }

      it { expect(page).to have_selector('h1', text: published_answer.translation_primary.title) }
    end
  end

  context '404' do
    before { visit help_answer_path(primary_locale.system_locale.locale, category, 12_345) }

    it { expect(page).to have_text('Page not found') }
  end
end
