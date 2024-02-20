class TransacoesController < ApplicationController
  def index
    cliente = Cliente.find(params[:cliente_id])

    render json: {
      saldo: {
        total: cliente.saldo,
        data_extrato: Time.current,
        limite: cliente.limite
      },
      ultimas_transacoes: cliente.transacoes.order(created_at: :desc).limit(10).map do |transacao|
        {
          valor: transacao.valor,
          tipo: transacao.tipo[0],
          descricao: transacao.descricao,
          realizada_em: transacao.created_at
        }
      end
    }, status: 200
  end

  def create
    money_transference = MoneyTransference.new.to(params[:cliente_id], transacao_params)

    cliente   = money_transference.cliente
    transacao = money_transference.transacao

    if transacao.persisted?
      render json: {
        limite: cliente.limite,
        saldo: cliente.saldo
      }, status: 200
    else
      render json: transacao.errors, status: :unprocessable_entity
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def transacao_params
      params.require(:transacao).permit(:valor, :tipo, :descricao)
    end
end
