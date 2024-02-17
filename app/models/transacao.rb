class Transacao < ApplicationRecord
  belongs_to :cliente

  enum :tipo, {credito: 'c', debito: 'd'}, validate: true

  validates :valor, numericality: { only_integer: true, greater_than: 0 }
  validates :descricao, length: { in: 1..10 }
end
