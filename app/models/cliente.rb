class Cliente < ApplicationRecord
  has_many :transacoes

  def saldo
    self.balance
  end

  def move_money!(transacao_params)
    me = self
    valor = transacao_params[:valor]

    self.with_lock do
      saldo_and_limite = (me.balance || me.saldo_inicial) + me.limite
      logger.debug("Saldo e limite: #{balance}, #{limite}, #{valor}, #{saldo_and_limite - valor}, #{saldo_and_limite - valor < 0}")
      transacao = me.transacoes.build(transacao_params)
      updated_balance = me.balance

      if transacao.credito?
        updated_balance += transacao.valor
      else
        if saldo_and_limite - valor < 0
          return transacao.tap do |t|
            t.errors.add(:base, :cliente_nao_tem_limite_suficiente)
          end
        end

        updated_balance -= transacao.valor
      end

      me.update_column(:balance, updated_balance)
      transacao.save

      transacao
    end
  end
end
