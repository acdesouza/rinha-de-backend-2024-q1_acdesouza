class Transacao < ApplicationRecord
  belongs_to :cliente

  enum :tipo, credito: 'c', debito: 'd'

  validates :valor, numericality: { only_integer: true, greater_than: 0 }
  validate :respects_cliente_limite

  private
  def respects_cliente_limite
    return if credito?

    if cliente.saldo - valor >= cliente.limite
      errors.add(:base, :cliente_nao_tem_limite_suficiente)
    end
  end
end
