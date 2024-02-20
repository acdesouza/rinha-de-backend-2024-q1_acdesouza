class Cliente < ApplicationRecord
  has_many :transacoes

  def saldo
    self.balance
  end
end
