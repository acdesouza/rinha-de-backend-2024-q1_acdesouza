class CreateTransacoes < ActiveRecord::Migration[7.1]
  def change
    create_table :transacoes do |t|
      t.bigint :valor
      t.string :tipo
      t.string :descricao
      t.references :cliente, foreign_key: true

      t.timestamps
    end
  end
end
