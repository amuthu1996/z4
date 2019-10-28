class AddColumnsToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :category, :string
    add_column :tickets, :are_you_victim, :boolean
    add_column :tickets, :victim, :string
    add_column :tickets, :others, :string
    add_column :tickets, :happening_now, :boolean
    add_column :tickets, :when_it_happend, :datetime
    add_column :tickets, :where, :string
    add_column :tickets, :anonymous, :boolean
  end
end
