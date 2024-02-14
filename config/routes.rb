Rails.application.routes.draw do
  post '/clientes/:cliente_id/transacoes', to: 'transacoes#create', as: :cliente_transacoes
  get  '/clientes/:cliente_id/extrato'   , to: 'transacoes#index',  as: :cliente_extrato

  get "up" => "rails/health#show", as: :rails_health_check
end
