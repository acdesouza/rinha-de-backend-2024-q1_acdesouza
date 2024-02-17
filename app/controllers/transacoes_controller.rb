class TransacoesController < ApplicationController
  before_action :set_cliente

  def index
    render json: {
      saldo: {
        total: @cliente.saldo,
        data_extrato: Time.current,
        limite: @cliente.limite
      },
      ultimas_transacoes: @cliente.transacoes.order(created_at: :desc).limit(10).map do |transacao|
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
    @transacao = @cliente.move_money!(transacao_params)

    if @transacao.persisted?
      render json: {
        limite: @cliente.limite,
        saldo: @cliente.saldo
      }, status: 200
    else
      render json: @transacao.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cliente
      @cliente = Cliente.find(params[:cliente_id])
    end

    # Only allow a list of trusted parameters through.
    def transacao_params
      params.require(:transacao).permit(:valor, :tipo, :descricao)
    end
end
