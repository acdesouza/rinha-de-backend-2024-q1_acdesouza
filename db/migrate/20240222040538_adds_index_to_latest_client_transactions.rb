class AddsIndexToLatestClientTransactions < ActiveRecord::Migration[7.1]
  def change
    add_index :transacoes, [:cliente_id, :created_at], if_not_exists: true, order: { created_at: :DESC }
  end
end
