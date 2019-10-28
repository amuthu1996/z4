# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class OrganizationsController < ApplicationController
  prepend_before_action :authentication_check

=begin

Format:
JSON

Example:
{
  "id":1,
  "name":"Znuny GmbH",
  "note":"",
  "active":true,
  "shared":true,
  "updated_at":"2012-09-14T17:51:53Z",
  "created_at":"2012-09-14T17:51:53Z",
  "created_by_id":2,
}

=end

=begin

Resource:
GET /api/v1/organizations

Response:
[
  {
    "id": 1,
    "name": "some_name1",
    ...
  },
  {
    "id": 2,
    "name": "some_name2",
    ...
  }
]

Test:
curl http://localhost/api/v1/organizations -v -u #{login}:#{password}

=end

  def index
    offset = 0
    per_page = 500

    if params[:page] && params[:per_page]
      offset = (params[:page].to_i - 1) * params[:per_page].to_i
      per_page = params[:per_page].to_i
    end

    if per_page > 500
      per_page = 500
    end

    # only allow customer to fetch his own organization
    organizations = []
    if !current_user.permissions?(['admin.organization', 'ticket.agent'])
      if current_user.organization_id
        organizations = Organization.where(id: current_user.organization_id).order(id: :asc).offset(offset).limit(per_page)
      end
    else
      organizations = Organization.all.order(id: :asc).offset(offset).limit(per_page)
    end

    if response_expand?
      list = []
      organizations.each do |organization|
        list.push organization.attributes_with_association_names
      end
      render json: list, status: :ok
      return
    end

    if response_full?
      assets = {}
      item_ids = []
      organizations.each do |item|
        item_ids.push item.id
        assets = item.assets(assets)
      end
      render json: {
        record_ids: item_ids,
        assets:     assets,
      }, status: :ok
      return
    end

    list = []
    organizations.each do |organization|
      list.push organization.attributes_with_association_ids
    end
    render json: list
  end

=begin

Resource:
GET /api/v1/organizations/#{id}

Response:
{
  "id": 1,
  "name": "name_1",
  ...
}

Test:
curl http://localhost/api/v1/organizations/#{id} -v -u #{login}:#{password}

=end

  def show

    # only allow customer to fetch his own organization
    if !current_user.permissions?(['admin.organization', 'ticket.agent'])
      if !current_user.organization_id
        render json: {}
        return
      end
      raise Exceptions::NotAuthorized if params[:id].to_i != current_user.organization_id
    end

    if response_expand?
      organization = Organization.find(params[:id]).attributes_with_association_names
      render json: organization, status: :ok
      return
    end

    if response_full?
      full = Organization.full(params[:id])
      render json: full, status: :ok
      return
    end

    model_show_render(Organization, params)
  end

=begin

Resource:
POST /api/v1/organizations

Payload:
{
  "name": "some_name",
  "active": true,
  "note": "some note",
  "shared": true
}

Response:
{
  "id": 1,
  "name": "some_name",
  ...
}

Test:
curl http://localhost/api/v1/organizations -v -u #{login}:#{password} -H "Content-Type: application/json" -X POST -d '{"name": "some_name","active": true,"shared": true,"note": "some note"}'

=end

  def create
    permission_check(['admin.organization', 'ticket.agent'])
    model_create_render(Organization, params)
  end

=begin

Resource:
PUT /api/v1/organizations/{id}

Payload:
{
  "id": 1
  "name": "some_name",
  "active": true,
  "note": "some note",
  "shared": true
}

Response:
{
  "id": 1,
  "name": "some_name",
  ...
}

Test:
curl http://localhost/api/v1/organizations -v -u #{login}:#{password} -H "Content-Type: application/json" -X PUT -d '{"id": 1,"name": "some_name","active": true,"shared": true,"note": "some note"}'

=end

  def update
    permission_check(['admin.organization', 'ticket.agent'])
    model_update_render(Organization, params)
  end

=begin

Resource:
DELETE /api/v1/organization/{id}

Response:
{}

Test:
curl http://localhost/api/v1/organization/{id} -v -u #{login}:#{password} -H "Content-Type: application/json" -X DELETE -d '{}'

=end

  def destroy
    permission_check(['admin.organization', 'ticket.agent'])
    model_references_check(Organization, params)
    model_destroy_render(Organization, params)
  end

  # GET /api/v1/organizations/search
  def search
    raise Exceptions::NotAuthorized if !current_user.permissions?(['admin.organization', 'ticket.agent'])

    per_page = params[:per_page] || params[:limit] || 100
    per_page = per_page.to_i
    if per_page > 500
      per_page = 500
    end
    page = params[:page] || 1
    page = page.to_i
    offset = (page - 1) * per_page

    query = params[:query]
    if query.respond_to?(:permit!)
      query = query.permit!.to_h
    end
    query_params = {
      query:        query,
      limit:        per_page,
      offset:       offset,
      sort_by:      params[:sort_by],
      order_by:     params[:order_by],
      current_user: current_user,
    }
    if params[:role_ids].present?
      query_params[:role_ids] = params[:role_ids]
    end

    # do query
    organization_all = Organization.search(query_params)

    if response_expand?
      list = []
      organization_all.each do |organization|
        list.push organization.attributes_with_association_names
      end
      render json: list, status: :ok
      return
    end

    # build result list
    if params[:label]
      organizations = []
      organization_all.each do |organization|
        a = { id: organization.id, label: organization.name, value: organization.name }
        organizations.push a
      end

      # return result
      render json: organizations
      return
    end

    if response_full?
      organization_ids = []
      assets = {}
      organization_all.each do |organization|
        assets = organization.assets(assets)
        organization_ids.push organization.id
      end

      # return result
      render json: {
        assets:           assets,
        organization_ids: organization_ids.uniq,
      }
      return
    end

    list = []
    organization_all.each do |organization|
      list.push organization.attributes_with_association_ids
    end
    render json: list, status: :ok
  end

  # GET /api/v1/organizations/history/1
  def history
    raise Exceptions::NotAuthorized if !current_user.permissions?(['admin.organization', 'ticket.agent'])

    # get organization data
    organization = Organization.find(params[:id])

    # get history of organization
    render json: organization.history_get(true)
  end

  # @path    [GET] /organizations/import_example
  #
  # @summary          Download of example CSV file.
  # @notes            The requester have 'admin.organization' permissions to be able to download it.
  # @example          curl -u 'me@example.com:test' http://localhost:3000/api/v1/organizations/import_example
  #
  # @response_message 200 File download.
  # @response_message 401 Invalid session.
  def import_example
    permission_check('admin.organization')
    send_data(
      Organization.csv_example,
      filename:    'organization-example.csv',
      type:        'text/csv',
      disposition: 'attachment'
    )
  end

  # @path    [POST] /organizations/import
  #
  # @summary          Starts import.
  # @notes            The requester have 'admin.text_module' permissions to be create a new import.
  # @example          curl -u 'me@example.com:test' -F 'file=@/path/to/file/organizations.csv' 'https://your.zammad/api/v1/organizations/import?try=true'
  # @example          curl -u 'me@example.com:test' -F 'file=@/path/to/file/organizations.csv' 'https://your.zammad/api/v1/organizations/import'
  #
  # @response_message 201 Import started.
  # @response_message 401 Invalid session.
  def import_start
    permission_check('admin.user')
    string = params[:data]
    if string.blank? && params[:file].present?
      string = params[:file].read.force_encoding('utf-8')
    end
    raise Exceptions::UnprocessableEntity, 'No source data submitted!' if string.blank?

    result = Organization.csv_import(
      string:       string,
      parse_params: {
        col_sep: params[:col_sep] || ',',
      },
      try:          params[:try],
      delete:       params[:delete],
    )
    render json: result, status: :ok
  end

end
