RSpec.shared_examples 'HasSearchIndexBackend' do |indexed_factory:|

  context '#search_index_update', performs_jobs: true do
    subject { create(indexed_factory) }

    before do
      allow(SearchIndexBackend).to receive(:enabled?).and_return(true)
    end

    context 'record indexing' do

      before do
        expect(subject).to be_present
      end

      it 'indexes on create' do
        expect(SearchIndexJob).to have_been_enqueued
      end

      it 'indexes on update' do
        clear_jobs
        subject.update(note: 'Updated')
        expect(SearchIndexJob).to have_been_enqueued
      end

      it 'indexes on touch' do
        clear_jobs
        subject.touch
        expect(SearchIndexJob).to have_been_enqueued
      end
    end
  end
end
