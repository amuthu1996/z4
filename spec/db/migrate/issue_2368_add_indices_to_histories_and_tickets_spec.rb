require 'rails_helper'

RSpec.describe Issue2368AddIndicesToHistoriesAndTickets, type: :db_migration do
  self.use_transactional_tests = false # see comments on #without_index method

  before { without_index(table, column: columns) }

  context 'for histories table' do
    let(:table) { :histories }

    context 'and related_o_id column' do
      let(:columns) { %i[related_o_id] }

      it 'adds an index' do
        expect { migrate }.to change { index_exists?(table, columns) }.to(true)
      end
    end

    context 'and related_history_object_id column' do
      let(:columns) { %i[related_history_object_id] }

      it 'adds an index' do
        expect { migrate }.to change { index_exists?(table, columns) }.to(true)
      end
    end

    context 'and o_id, history_object_id, & related_o_id columns' do
      let(:columns) { %i[o_id history_object_id related_o_id] }

      it 'adds a composite index' do
        expect { migrate }.to change { index_exists?(table, columns) }.to(true)
      end
    end
  end

  context 'for tickets table' do
    let(:table) { :tickets }

    context 'and group_id & state_id columns' do
      let(:columns) { %i[group_id state_id] }

      it 'adds a composite index' do
        expect { migrate }.to change { index_exists?(table, columns) }.to(true)
      end
    end

    context 'and group_id, state_id, & owner_id columns' do
      let(:columns) { %i[group_id state_id owner_id] }

      it 'adds a composite index' do
        expect { migrate }.to change { index_exists?(table, columns) }.to(true)
      end
    end
  end
end
