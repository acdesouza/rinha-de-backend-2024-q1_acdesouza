require "test_helper"

class TransacoesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cliente = clientes(:cliente_one)
  end

  test "should show Cliente's Extrato with last 10 Transacoes" do
    transacao_01 = transacoes(:cliente_one_first)
    transacao_02 = transacoes(:cliente_one_second)
    transacao_03 = transacoes(:cliente_one_third)

    travel_to Time.current do
      get cliente_extrato_url(cliente_id: @cliente.id)
      assert_response :success

      expected_response = {
        saldo: {
          total: @cliente.saldo,
          data_extrato: Time.current,
          limite: @cliente.limite
        },
        ultimas_transacoes: [transacao_03, transacao_02, transacao_01].map do |transacao|
          {
            valor: transacao.valor,
            tipo: transacao.tipo[0],
            descricao: transacao.descricao,
            realizada_em: transacao.created_at
          }
        end
      }.to_json
      assert_equal expected_response, response.body
    end
  end

  test "should response with 404 for Cliente's Extrato using unknown Cliente#id" do
    get cliente_extrato_url(cliente_id: 666)
    assert_response :not_found
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

  test "should NOT create transacao empty descricao" do
    assert_no_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: 1000,
        tipo: "c",
        descricao: ""
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should NOT create transacao using more than 10 chars for descricao" do
    assert_no_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: 1000,
        tipo: "c",
        descricao: "DESCRICAO_TOO_LONG"
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should NOT create transacao with a tipo different from c or d" do
    assert_no_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: @cliente.id), params: {
        valor: 1000,
        tipo: "w",
        descricao: "WRONG_TIPO"
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should NOT create transacao without a valid Cliente" do
    non_existing_client_id = 666
    assert_no_difference("Transacao.count") do
      post cliente_transacoes_url(cliente_id: non_existing_client_id), params: {
        valor: 1000,
        tipo: "c",
        descricao: "NON_CLIENT"
      }, as: :json
    end

    assert_response :not_found
  end
end
