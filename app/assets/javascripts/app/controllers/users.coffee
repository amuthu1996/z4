class Index extends App.ControllerSubContent
  requiredPermission: 'admin.user'
  header: 'Users'
  elements:
    '.js-search': 'searchInput'
  events:
    'click [data-type=new]': 'new'
    'click [data-type=import]': 'import'

  constructor: ->
    super
    @render()

  show: =>
    super
    return if !@table
    @table.show()

  hide: =>
    super
    return if !@table
    @table.hide()

  render: ->
    @html App.view('user')(
      head: 'Users'
      buttons: [
        { name: 'Import', 'data-type': 'import', class: 'btn' }
        { name: 'New User', 'data-type': 'new', class: 'btn--success' }
      ]
      roles: App.Role.findAllByAttribute('active', true)
    )

    @$('.tab').on(
      'click'
      (e) =>
        e.preventDefault()
        $(e.target).toggleClass('active')
        query = @searchInput.val().trim()
        @query = query
        @delay(@search, 220, 'search')
    )

    # start search
    @searchInput.bind( 'keyup', (e) =>
      query = @searchInput.val().trim()
      return if query is @query
      @query = query
      @delay(@search, 220, 'search')
    )

    # show last 20 users
    @search()

  renderResult: (user_ids = []) ->
    @stopLoading()

    callbackHeader = (header) ->
      attribute =
        name:         'switch_to'
        display:      'Action'
        className:    'actionCell'
        translation:  true
        width:        '250px'
        displayWidth: 250
        unresizable:  true
      header.push attribute
      header

    callbackAttributes = (value, object, attribute, header) ->
      text                  = App.i18n.translateInline('View from user\'s perspective')
      value                 = ' '
      attribute.raw         = ' <span class="btn btn--primary btn--small btn--slim switchView" title="' + text + '">' + App.Utils.icon('switchView') + '<span>' + text + '</span></span>'
      attribute.class       = ''
      attribute.parentClass = 'actionCell no-padding'
      attribute.link        = ''
      attribute.title       = App.i18n.translateInline('Switch to')
      value

    switchTo = (id,e) =>
      e.preventDefault()
      e.stopPropagation()
      @disconnectClient()
      $('#app').hide().attr('style', 'display: none!important')
      @delay(
        =>
          App.Auth._logout(false)
          @ajax(
            id:          'user_switch'
            type:        'GET'
            url:         "#{@apiPath}/sessions/switch/#{id}"
            success:     (data, status, xhr) =>
              location = "#{window.location.protocol}//#{window.location.host}#{data.location}"
              @windowReload(undefined, location)
          )
        800
      )

    edit = (id, e) =>
      e.preventDefault()
      item = App.User.find(id)

      rerender = =>
        App.Group.fetch()
        @renderResult(user_ids)

      new App.ControllerGenericEdit(
        id: item.id
        pageData:
          title:     'Users'
          home:      'users'
          object:    'User'
          objects:   'Users'
          navupdate: '#users'
        genericObject: 'User'
        callback: rerender
        container: @el.closest('.content')
      )

    users = []
    for user_id in user_ids
      user = App.User.find(user_id)
      users.push user

    @$('.table-overview').html('')
    @table = new App.ControllerTable(
      tableId: 'users_admin_overview'
      el:      @$('.table-overview')
      model:   App.User
      objects: users
      class:   'user-list'
      callbackHeader: [callbackHeader]
      callbackAttributes:
        switch_to: [
          callbackAttributes
        ]
      bindCol:
        switch_to:
          events:
            'click': switchTo
      bindRow:
        events:
          'click': edit
    )

  search: =>
    role_ids = []
    @$('.tab.active').each( (i,d) ->
      role_ids.push $(d).data('id')
    )
    @startLoading(@$('.table-overview'))
    App.Ajax.request(
      id: 'search'
      type: 'GET'
      url: "#{@apiPath}/users/search?sort_by=created_at"
      data:
        query: @query || '*'
        limit: 50
        role_ids: role_ids
        full:  true
      processData: true,
      success: (data, status, xhr) =>
        App.Collection.loadAssets(data.assets)
        @renderResult(data.user_ids)
        @stopLoading()
      done: =>
        @stopLoading()
    )

  new: (e) ->
    e.preventDefault()
    new App.ControllerGenericNew(
      pageData:
        title:     'Users'
        home:      'users'
        object:    'User'
        objects:   'Users'
        navupdate: '#users'
      genericObject: 'User'
      container: @el.closest('.content')
      callback: @search
    )

  import: (e) ->
    e.preventDefault()
    new App.Import(
      baseUrl: '/api/v1/users'
      container: @el.closest('.content')
    )

App.Config.set( 'User', { prio: 1000, name: 'Users', parent: '#manage', target: '#manage/users', controller: Index, permission: ['admin.user'] }, 'NavBarAdmin' )
