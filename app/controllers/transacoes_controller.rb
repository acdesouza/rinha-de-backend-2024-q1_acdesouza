class TransacoesController < ApplicationController
  before_action :set_cliente

  def create
    @transacao = @cliente.transacoes.build(transacao_params)

    if @transacao.save
      render json: {
        limite: @cliente.limite,
        saldo: @cliente.saldo
      }, status: 200
    else
      render json: @transacao.errors, status: :unprocessable_entity
    end
  end

  private
    def set_cliente
      @cliente = Cliente.find(params[:cliente_id])
    end

    def transacao_params
      params.require(:transacao).permit(:valor, :tipo, :descricao)
    end
end
