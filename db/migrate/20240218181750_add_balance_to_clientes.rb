class AddBalanceToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :balance, :bigint, default: 0, null: false
  end
end
