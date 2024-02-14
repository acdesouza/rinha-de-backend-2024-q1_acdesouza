Rails.application.routes.draw do
  post '/clientes/:cliente_id/transacoes', to: 'transacoes#create', as: :cliente_transacoes

  get "up" => "rails/health#show", as: :rails_health_check
end
