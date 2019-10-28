require 'rails_helper'

RSpec.describe 'Api Auth', type: :request do

  around do |example|
    orig = ActionController::Base.allow_forgery_protection

    begin
      ActionController::Base.allow_forgery_protection = true
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = orig
    end
  end

  let(:admin_user) do
    create(:admin_user)
  end
  let(:agent_user) do
    create(:agent_user)
  end
  let(:customer_user) do
    create(:customer_user)
  end

  describe 'request handling' do

    it 'does basic auth - admin' do

      Setting.set('api_password_access', false)
      authenticated_as(admin_user)
      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API password access disabled!')

      Setting.set('api_password_access', true)
      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response).to be_truthy
    end

    it 'does basic auth - agent' do

      Setting.set('api_password_access', false)
      authenticated_as(agent_user)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API password access disabled!')

      Setting.set('api_password_access', true)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy
    end

    it 'does basic auth - customer' do

      Setting.set('api_password_access', false)
      authenticated_as(customer_user)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API password access disabled!')

      Setting.set('api_password_access', true)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy
    end

    it 'does token auth - admin', last_admin_check: false do

      admin_token = create(
        :token,
        action:      'api',
        persistent:  true,
        user_id:     admin_user.id,
        preferences: {
          permission: ['admin.session'],
        },
      )

      authenticated_as(admin_user, token: admin_token)

      Setting.set('api_token_access', false)
      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API token access disabled!')

      Setting.set('api_token_access', true)
      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')

      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response).to be_truthy

      admin_token.preferences[:permission] = ['admin.session_not_existing']
      admin_token.save!

      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('Not authorized (token)!')

      admin_token.preferences[:permission] = []
      admin_token.save!

      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('Not authorized (token)!')

      admin_user.active = false
      admin_user.save!

      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('User is inactive!')

      admin_token.preferences[:permission] = ['admin.session']
      admin_token.save!

      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('User is inactive!')

      admin_user.active = true
      admin_user.save!

      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response).to be_truthy

      get '/api/v1/roles', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('Not authorized (token)!')

      admin_token.preferences[:permission] = ['admin.session_not_existing', 'admin.role']
      admin_token.save!

      get '/api/v1/roles', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      admin_token.preferences[:permission] = ['ticket.agent']
      admin_token.save!

      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)}"
      post '/api/v1/organizations', params: { name: name }, as: :json
      expect(response).to have_http_status(:created)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to eq(name)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)} - 2"
      put "/api/v1/organizations/#{json_response['id']}", params: { name: name }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to eq(name)
      expect(json_response).to be_truthy

      admin_token.preferences[:permission] = ['admin.organization']
      admin_token.save!

      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)}"
      post '/api/v1/organizations', params: { name: name }, as: :json
      expect(response).to have_http_status(:created)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to eq(name)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)} - 2"
      put "/api/v1/organizations/#{json_response['id']}", params: { name: name }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to eq(name)
      expect(json_response).to be_truthy

      admin_token.preferences[:permission] = ['admin']
      admin_token.save!

      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)}"
      post '/api/v1/organizations', params: { name: name }, as: :json
      expect(response).to have_http_status(:created)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to eq(name)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)} - 2"
      put "/api/v1/organizations/#{json_response['id']}", params: { name: name }, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to eq(name)
      expect(json_response).to be_truthy

    end

    it 'does token auth - agent' do

      agent_token = create(
        :token,
        action:     'api',
        persistent: true,
        user_id:    agent_user.id,
      )

      authenticated_as(agent_user, token: agent_token)

      Setting.set('api_token_access', false)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API token access disabled!')

      Setting.set('api_token_access', true)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)}"
      post '/api/v1/organizations', params: { name: name }, as: :json
      expect(response).to have_http_status(:unauthorized)

    end

    it 'does token auth - customer' do

      customer_token = create(
        :token,
        action:     'api',
        persistent: true,
        user_id:    customer_user.id,
      )

      authenticated_as(customer_user, token: customer_token)

      Setting.set('api_token_access', false)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API token access disabled!')

      Setting.set('api_token_access', true)
      get '/api/v1/tickets', params: {}, as: :json
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      name = "some org name #{rand(999_999_999)}"
      post '/api/v1/organizations', params: { name: name }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does token auth - invalid user - admin', last_admin_check: false do

      admin_token = create(
        :token,
        action:     'api',
        persistent: true,
        user_id:    admin_user.id,
      )

      authenticated_as(admin_user, token: admin_token)

      admin_user.active = false
      admin_user.save!

      Setting.set('api_token_access', false)
      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('API token access disabled!')

      Setting.set('api_token_access', true)
      get '/api/v1/sessions', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('User is inactive!')
    end

    it 'does token auth - expired' do

      Setting.set('api_token_access', true)

      admin_token = create(
        :token,
        action:     'api',
        persistent: true,
        user_id:    admin_user.id,
        expires_at: Time.zone.today
      )

      authenticated_as(admin_user, token: admin_token)

      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['error']).to eq('Not authorized (token expired)!')

      admin_token.reload
      expect(admin_token.last_used_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'does token auth - not expired' do

      Setting.set('api_token_access', true)

      admin_token = create(
        :token,
        action:     'api',
        persistent: true,
        user_id:    admin_user.id,
        expires_at: Time.zone.tomorrow
      )

      authenticated_as(admin_user, token: admin_token)

      get '/api/v1/tickets', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.header['Access-Control-Allow-Origin']).to eq('*')
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response).to be_truthy

      admin_token.reload
      expect(admin_token.last_used_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'does session auth - admin' do
      create(:admin_user, login: 'api-admin@example.com', password: 'adminpw')

      get '/'
      token = response.headers['CSRF-TOKEN']

      post '/api/v1/signin', params: { username: 'api-admin@example.com', password: 'adminpw', fingerprint: '123456789' }, headers: { 'X-CSRF-Token' => token }
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(response).to have_http_status(:created)

      get '/api/v1/sessions', params: {}
      expect(response).to have_http_status(:ok)
      expect(response.header).not_to be_key('Access-Control-Allow-Origin')
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response).to be_truthy
    end

    it 'does session auth - admin - only with valid CSRF token' do
      create(:admin_user, login: 'api-admin@example.com', password: 'adminpw')

      post '/api/v1/signin', params: { username: 'api-admin@example.com', password: 'adminpw', fingerprint: '123456789' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
