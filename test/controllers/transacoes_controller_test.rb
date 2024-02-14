require "test_helper"

class TransacoesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cliente = clientes(:cliente_one)
  end

  test "should create transacao de credito" do
    assert_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: 1000,
        tipo: "c",
        descricao: "descricao"
      }, as: :json
    end

    assert_response :success

    expected_cliente_account = {
      limite: 4200,
      saldo:  5200
    }.to_json
    assert_equal expected_cliente_account, response.body
  end

  test "should create transacao de debito" do
    assert_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: 1000,
        tipo: "d",
        descricao: "descricao"
      }, as: :json
    end

    assert_response :success

    expected_cliente_account = {
      limite: 4200,
      saldo:  3200
    }.to_json
    assert_equal expected_cliente_account, response.body
  end

  test "should NOT create transacao de debito breaking the Cliente limite" do
    value_to_attempt_to_break_limit = @cliente.saldo - @cliente.saldo - (@cliente.limite + 1)

    assert_no_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: value_to_attempt_to_break_limit,
        tipo: "d",
        descricao: "QUEBRLIMIT"
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should NOT create transacao using a negative number on valor" do
    assert_no_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: -10,
        tipo: "c",
        descricao: "NEG_VALUE"
      }, as: :json
    end

    assert_response :unprocessable_entity
  end
end
