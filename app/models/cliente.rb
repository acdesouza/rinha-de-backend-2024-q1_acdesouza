class Cliente < ApplicationRecord
  has_many :transacoes

  def saldo
    self.with_lock do
    creditos = transacoes.credito.sum(:valor)
    debitos  = transacoes.debito.sum(:valor)

    saldo_inicial + creditos - debitos
    end
  end

  def move_money!(transacao_params)
    valor = transacao_params[:valor]

    self.with_lock do
      saldo_and_limite = saldo + limite
      logger.debug "Saldo e limite: #{saldo}, #{limite}, #{valor}, #{saldo_and_limite - valor}, #{saldo_and_limite - valor < 0}"

      transacao = self.transacoes.build(transacao_params)


      if transacao.debito? && (saldo_and_limite - valor < 0)
        transacao.errors.add(:base, :cliente_nao_tem_limite_suficiente)
      else
        transacao.save
      end

      transacao
    end
  end
end
