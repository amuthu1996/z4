Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # overviews
  match api_path + '/packages',           to: 'packages#index',      via: :get
  match api_path + '/packages',           to: 'packages#install',    via: :post
  match api_path + '/packages',           to: 'packages#uninstall',  via: :delete

end
