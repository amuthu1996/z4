class ChangeColumnTypeOfAnonymousOngoing < ActiveRecord::Migration[5.2]
  def change
    change_column :tickets, :anonymous, :string
    change_column :tickets, :ongoing, :string
  end
end
