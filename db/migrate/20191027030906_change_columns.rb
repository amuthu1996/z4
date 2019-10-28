class ChangeColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :tickets, :when_it_happend, :when_it_happened
    rename_column :tickets, :happening_now, :ongoing

  end
end
