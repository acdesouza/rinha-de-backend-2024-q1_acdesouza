class Cliente < ApplicationRecord
  has_many :transacoes

  def saldo
    creditos = transacoes.credito.sum(:valor)
    debitos  = transacoes.debito.sum(:valor)

    saldo_inicial + creditos - debitos
  end
end
