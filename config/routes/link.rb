Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # links
  match api_path + '/links',             to: 'links#index',   via: :get
  match api_path + '/links/add',         to: 'links#add',     via: :get
  match api_path + '/links/remove',      to: 'links#remove',  via: :get

end
