class App.GlobalSearchWidget extends Spine.Module
  shiftHeld = false

  constructor: ->
    $('body').on('mousedown', (e) =>
      @shiftHeldToogle(e)
      true
    )
    App.Event.bind('global:search:set', (data) =>
      item = data[0]
      attribute = data[1]
      item = item.replace('"', '')
      if item.match(/\W/)
        item = "\"#{item}\""
      if !attribute
        searchAttribute = "#{item}"
      else
        searchAttribute = "#{attribute}:#{item}"
      currentValue = $('#global-search').val()

      if @shiftHeld && currentValue
        currentValue += ' AND '
        currentValue += searchAttribute
      else
        currentValue = searchAttribute

      $('#global-search').val(currentValue)
      delay = ->
        $('#global-search').focus()
      App.Delay.set(delay, 20, 'global-search-delay')
    )

  shiftHeldToogle: (e) ->
    @shiftHeld = e.shiftKey

  @search: (item, attribute) ->
    App.Event.trigger('global:search:set', [item, attribute])

App.Config.set('global_navigation', App.GlobalSearchWidget, 'Widgets')
