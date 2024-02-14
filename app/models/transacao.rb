class Transacao < ApplicationRecord
  belongs_to :cliente

  enum :tipo, credito: 'c', debito: 'd'
end
