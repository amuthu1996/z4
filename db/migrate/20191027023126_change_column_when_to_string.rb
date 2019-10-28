class ChangeColumnWhenToString < ActiveRecord::Migration[5.2]
  def change
    change_column :tickets, :when_it_happend, :string
  end
end
