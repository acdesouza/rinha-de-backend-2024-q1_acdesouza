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
end
