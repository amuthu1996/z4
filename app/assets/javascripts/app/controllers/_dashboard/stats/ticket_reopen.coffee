class Stats extends App.Controller
  constructor: ->
    super
    @load()

  load: =>
    stats_store = App.StatsStore.first()
    if stats_store
      @render(stats_store.data)
    else
      @render()

  render: (data = {}) ->
    if !data.StatsTicketReopen
      data.StatsTicketReopen =
        state: 'supergood'
        percent: 0
        average_per_agent: 0

    data.StatsTicketReopen.description = 'How many of your tickets have been re-opened after being marked “closed”?'

    content = App.view('dashboard/stats/ticket_reopen')(data)
    if @$('.ticket_reopen').length > 0
      @$('.ticket_reopen').html(content)
    else
      @el.append(content)

App.Config.set('ticket_reopen', {controller: Stats, permission: 'ticket.agent', prio: 600 }, 'Stats')
