require 'rails_helper'

RSpec.describe 'User Organization', type: :request, searchindex: true do

  let!(:admin_user) do
    create(:admin_user, groups: Group.all)
  end
  let!(:agent_user) do
    create(:agent_user, groups: Group.all)
  end
  let!(:customer_user) do
    create(:customer_user)
  end
  let!(:organization) do
    create(:organization, name: 'Rest Org', note: 'Rest Org A')
  end
  let!(:organization2) do
    create(:organization, name: 'Rest Org #2', note: 'Rest Org B')
  end
  let!(:organization3) do
    create(:organization, name: 'Rest Org #3', note: 'Rest Org C')
  end
  let!(:customer_user2) do
    create(:customer_user, organization: organization)
  end

  before do
    configure_elasticsearch do

      travel 1.minute

      rebuild_searchindex

      # execute background jobs
      Scheduler.worker(true)

      sleep 6
    end
  end

  describe 'request handling' do

    it 'does organization index with agent' do
      authenticated_as(agent_user)
      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response[0]['member_ids']).to be_a_kind_of(Array)
      expect(json_response.length >= 3).to be_truthy

      get '/api/v1/organizations?limit=40&page=1&per_page=2', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.class).to eq(Array)
      organizations = Organization.order(:id).limit(2)
      expect(json_response[0]['id']).to eq(organizations[0].id)
      expect(json_response[0]['member_ids']).to eq(organizations[0].member_ids)
      expect(json_response[1]['id']).to eq(organizations[1].id)
      expect(json_response[1]['member_ids']).to eq(organizations[1].member_ids)
      expect(json_response.count).to eq(2)

      get '/api/v1/organizations?limit=40&page=2&per_page=2', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.class).to eq(Array)
      organizations = Organization.order(:id).limit(4)
      expect(json_response[0]['id']).to eq(organizations[2].id)
      expect(json_response[0]['member_ids']).to eq(organizations[2].member_ids)
      expect(json_response[1]['id']).to eq(organizations[3].id)
      expect(json_response[1]['member_ids']).to eq(organizations[3].member_ids)

      expect(json_response.count).to eq(2)

      # show/:id
      get "/api/v1/organizations/#{organization.id}", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['member_ids']).to be_a_kind_of(Array)
      expect(json_response['members']).to be_falsey
      expect('Rest Org').to eq(json_response['name'])

      get "/api/v1/organizations/#{organization2.id}", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['member_ids']).to be_a_kind_of(Array)
      expect(json_response['members']).to be_falsey
      expect('Rest Org #2').to eq(json_response['name'])

      # search as agent
      Scheduler.worker(true)
      get "/api/v1/organizations/search?query=#{CGI.escape('Zammad')}", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.class).to eq(Array)
      expect(json_response[0]['name']).to eq('Zammad Foundation')
      expect(json_response[0]['member_ids']).to be_truthy
      expect(json_response[0]['members']).to be_falsey

      get "/api/v1/organizations/search?query=#{CGI.escape('Zammad')}&expand=true", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.class).to eq(Array)
      expect(json_response[0]['name']).to eq('Zammad Foundation')
      expect(json_response[0]['member_ids']).to be_truthy
      expect(json_response[0]['members']).to be_truthy

      get "/api/v1/organizations/search?query=#{CGI.escape('Zammad')}&label=true", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response.class).to eq(Array)
      expect(json_response[0]['label']).to eq('Zammad Foundation')
      expect(json_response[0]['value']).to eq('Zammad Foundation')
      expect(json_response[0]['member_ids']).to be_falsey
      expect(json_response[0]['members']).to be_falsey
    end

    it 'does organization index with customer1' do
      authenticated_as(customer_user)
      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response.length).to eq(0)

      # show/:id
      get "/api/v1/organizations/#{organization.id}", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to be_nil

      get "/api/v1/organizations/#{organization2.id}", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to be_nil

      # search
      Scheduler.worker(true)
      get "/api/v1/organizations/search?query=#{CGI.escape('Zammad')}", params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does organization index with customer2' do
      authenticated_as(customer_user2)
      get '/api/v1/organizations', params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Array)
      expect(json_response.length).to eq(1)

      # show/:id
      get "/api/v1/organizations/#{organization.id}", params: {}, as: :json
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_a_kind_of(Hash)
      expect('Rest Org').to eq(json_response['name'])

      get "/api/v1/organizations/#{organization2.id}", params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json_response).to be_a_kind_of(Hash)
      expect(json_response['name']).to be_nil

      # search
      Scheduler.worker(true)
      get "/api/v1/organizations/search?query=#{CGI.escape('Zammad')}", params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
