class MoneyTransference
  attr_reader :cliente, :transacao

  def to(cliente_id, transacao_params)
    me = self
    Cliente.transaction do
      @cliente = Cliente.find(cliente_id).lock!

      saldo_and_limite = (@cliente.balance || @cliente.saldo_inicial) + @cliente.limite
      valor            = transacao_params[:valor]

      Rails.logger.debug("Cliente: #{@cliente.inspect}")
      Rails.logger.debug("Saldo e limite: #{saldo_and_limite}")
      Rails.logger.debug("Transação Nova: #{transacao_params.inspect}")

      @transacao = @cliente.transacoes.build(transacao_params)
      updated_balance = @cliente.balance

      if @transacao.credito?
        updated_balance += @transacao.valor
      else
        if saldo_and_limite - valor < 0
          @transacao.errors.add(:base, :cliente_nao_tem_limite_suficiente)
          return me
        end

        updated_balance -= @transacao.valor
      end

      @cliente.update_column(:balance, updated_balance)
      @transacao.save!
    end

    self
  end
end
