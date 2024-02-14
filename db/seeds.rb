# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  [1,   100000, 0],
  [2,    80000, 0],
  [3,  1000000, 0],
  [4, 10000000, 0],
  [5,   500000, 0]
].each do |cliente_row|
  Cliente.create(
    id:            cliente_row[0],
    limite:        cliente_row[1],
    saldo_inicial: cliente_row[2],
  )
end
