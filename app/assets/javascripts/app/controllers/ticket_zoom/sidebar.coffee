class App.TicketZoomSidebar extends App.ObserverController
  model: 'Ticket'
  observe:
    customer_id: true
    organization_id: true

  reload: (args) =>
    for key, backend of @sidebarBackends
      if backend && backend.reload
        backend.reload(args)

  commit: (args) =>
    for key, backend of @sidebarBackends
      if backend && backend.commit
        backend.commit(args)

  postParams: (args) =>
    for key, backend of @sidebarBackends
      if backend && backend.postParams
        backend.postParams(args)

  render: (ticket) =>
    @sidebarBackends ||= {}
    @sidebarItems = []
    sidebarBackends = App.Config.get('TicketZoomSidebar')
    keys = _.keys(sidebarBackends).sort()
    for key in keys
      if !@sidebarBackends[key] || !@sidebarBackends[key].reload
        @sidebarBackends[key] = new sidebarBackends[key](
          ticket:   ticket
          query:    @query
          taskGet:  @taskGet
          taskKey:  @taskKey
          formMeta: @formMeta
          markForm: @markForm
          tags:     @tags
          links:    @links
        )
      else
        @sidebarBackends[key].reload(
          params:   @params
          query:    @query
          formMeta: @formMeta
          markForm: @markForm
          tags:     @tags
          links:    @links
        )
      @sidebarItems.push @sidebarBackends[key]

    new App.Sidebar(
      el:           @el.find('.tabsSidebar')
      sidebarState: @sidebarState
      items:        @sidebarItems
    )
