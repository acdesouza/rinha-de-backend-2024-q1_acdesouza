require "test_helper"

class ClienteTest < ActiveSupport::TestCase
  test "should prevent race condition to disrespect cliente limite" do
    cliente = clientes(:cliente_one)
    cliente_transacoes_count = cliente.transacoes.count
    cliente_saldo_and_limite = cliente.saldo + cliente.limite

    assert_equal(5, ActiveRecord::Base.connection.pool.size)
    begin
      concurrency_level = 4
      should_wait = true

      statuses = {}

      threads = Array.new(concurrency_level) do |i|
        Thread.new do
          true while should_wait
          # Unique validation for key values exists scoped to keyboard
          # transacao = cliente.transacoes.build(
          #   valor: cliente_saldo_and_limite,
          #   tipo: 'd',
          #   descricao: 'RACE_COND'
          # )
          transacao = cliente.move_money!({
            valor: cliente_saldo_and_limite,
            tipo: 'd',
            descricao: 'RACE_COND'
          })
          statuses[i] = transacao.persisted?
        end
      end
      should_wait = false
      threads.each(&:join)

      cliente.reload
      assert_equal(0, cliente.saldo + cliente.limite)
      assert_equal(cliente_transacoes_count + 1, cliente.transacoes.count)
      assert_equal(1, statuses.count { |_k, v| v })
      assert_equal(3, statuses.count { |_k, v| !v })
    ensure
      ActiveRecord::Base.connection_pool.disconnect!
    end
  end
end
