Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # roles
  match api_path + '/roles',            to: 'roles#index',   via: :get
  match api_path + '/roles/:id',        to: 'roles#show',    via: :get
  match api_path + '/roles',            to: 'roles#create',  via: :post
  match api_path + '/roles/:id',        to: 'roles#update',  via: :put

end
