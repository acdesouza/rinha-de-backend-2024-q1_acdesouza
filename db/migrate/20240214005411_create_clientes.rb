class CreateClientes < ActiveRecord::Migration[7.1]
  def change
    create_table :clientes do |t|
      t.bigint :limite
      t.bigint :saldo_inicial

      t.timestamps
    end
  end
end
