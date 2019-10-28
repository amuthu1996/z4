class App.Ticket extends App.Model
  @configure 'Ticket', 'number', 'title', 'group_id', 'owner_id', 'customer_id', 'state_id', 'priority_id', 'are_you_victim', 'anonymous','victim', 'where', 'when_it_happened', 'article', 'others', 'ongoing', 'tags', 'links', 'updated_at', 'preferences', 'category'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/tickets'
  @configure_attributes = [
      { name: 'number',                   display: '#',            tag: 'input',    type: 'text', limit: 100, null: true, readonly: 1, width: '68px' },
      { name: 'title',                    display: 'Title_',        tag: 'input',    type: 'text', limit: 100, null: false },
      { name: 'customer_id',              display: 'Customer',     tag: 'input',    type: 'text', limit: 100, null: false, autocapitalize: false, relation: 'User' },
      { name: 'organization_id',          display: 'Organization', tag: 'select',   relation: 'Organization', readonly: 1 },
      { name: 'group_id',                 display: 'Group',        tag: 'select',   multiple: false, limit: 100, null: false, relation: 'Group', width: '10%', edit: true },
      { name: 'owner_id',                 display: 'Owner',        tag: 'select',   multiple: false, limit: 100, null: true, relation: 'User', width: '12%', edit: true },
      { name: 'state_id',                 display: 'State',        tag: 'select',   multiple: false, null: false, relation: 'TicketState', default: 'new', width: '12%', edit: true, customer: true },
      { name: 'pending_time',             display: 'Pending till', tag: 'datetime', null: true, width: '130px' },
      { name: 'priority_id',              display: 'Priority',     tag: 'select',   multiple: false, null: false, relation: 'TicketPriority', default: '2 normal', width: '54px', edit: true, customer: true },
      { name: 'article_count',            display: 'Article#',     readonly: 1, width: '12%' },
      { name: 'time_unit',                display: 'Accounted Time',          readonly: 1, width: '12%' },
      { name: 'escalation_at',            display: 'Escalation at',           tag: 'datetime', null: true, readonly: 1, width: '110px', class: 'escalation' },
      { name: 'last_contact_at',          display: 'Last contact',            tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'last_contact_agent_at',    display: 'Last contact (agent)',    tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'last_contact_customer_at', display: 'Last contact (customer)', tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'first_response_at',        display: 'First response',          tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'close_at',                 display: 'Closing time',              tag: 'datetime', null: true, readonly: 1, width: '110px' },
      { name: 'created_by_id',            display: 'Created by',   relation: 'User', readonly: 1 },
      { name: 'created_at',               display: 'Created at',   tag: 'datetime', width: '110px', align: 'right', readonly: 1 },
      { name: 'updated_by_id',            display: 'Updated by',   relation: 'User', readonly: 1 },
      { name: 'updated_at',               display: 'Updated at',   tag: 'datetime', width: '110px', align: 'right', readonly: 1 },
      { name: 'category',                 display: 'category', tag:'input', type:"text", limit:100, null: false },
      { name: 'are_you_victim',           display: 'are_you_victim', tag:'select', type:'checkbox', limit:100, null: true, default: 'false' },
      { name: 'victim',                   display: 'victim', tag:'input', type:'text', limit:100, null: true },
      { name: 'others',                   display: 'others', tag:'input', type:'text', limit:100, null: true },
      { name: 'ongoing',            display: 'ongoing', tag:'select', type:'checkbox', limit:100, null: true, default: 'false' },
      { name: 'when_it_happened',          display: 'when_it_happened',  tag:'input', type:'text', null: true, readonly: 1, width: '110px' },
      { name: 'where',                    display: 'where', tag:"input", type:'text' , limit: 100, null: false  },
      { name:'anonymous',                display: 'anonymous', tag:"select", type:'checkbox' , limit: 100, null: true, default: 'false'  },
    ]

  uiUrl: ->
    "#ticket/zoom/#{@id}"

  priorityIcon: ->
    priority = App.TicketPriority.findNative(@priority_id)
    return '' if !priority
    return '' if !priority.ui_icon
    return '' if !priority.ui_color
    App.Utils.icon(priority.ui_icon, "u-#{priority.ui_color}-color")

  priorityClass: ->
    priority = App.TicketPriority.findNative(@priority_id)
    return '' if !priority
    return '' if !priority.ui_color
    "item--#{priority.ui_color}"

  rowClass: ->
    @priorityClass()

  getState: ->
    type = App.TicketState.findNative(@state_id)
    stateType = App.TicketStateType.findNative(type.state_type_id)
    state = 'closed'
    if stateType.name is 'new' || stateType.name is 'open'
      state = 'open'

      # if ticket is escalated, overwrite state
      if @escalation_at && new Date( Date.parse(@escalation_at) ) < new Date
        state = 'escalating'
    else if stateType.name is 'pending reminder'
      state = 'pending'

      # if ticket pending_time is reached, overwrite state
      if @pending_time && new Date( Date.parse(@pending_time) ) < new Date
        state = 'open'
    else if stateType.name is 'pending action'
      state = 'pending'
    state

  icon: ->
    'task-state'

  iconClass: ->
    @getState()

  iconTitle: ->
    type = App.TicketState.findNative(@state_id)
    stateType = App.TicketStateType.findNative(type.state_type_id)
    if stateType.name is 'pending reminder' && @pending_time && new Date( Date.parse(@pending_time) ) < new Date
      return "#{App.i18n.translateInline(type.displayName())} - #{App.i18n.translateInline('reached')}"
    if @escalation_at && new Date( Date.parse(@escalation_at) ) < new Date
      return "#{App.i18n.translateInline(type.displayName())} - #{App.i18n.translateInline('escalated')}"
    App.i18n.translateInline(type.displayName())

  iconTextClass: ->
    "task-state-#{ @getState() }-color"

  iconActivity: (user) ->
    return if !user
    if @owner_id == user.id
      return 'important'
    ''
  searchResultAttributes: ->
    display:    "##{@number} - #{@title}"
    id:         @id
    class:      "task-state-#{ @getState() } ticket-popover"
    url:        @uiUrl()
    icon:       'task-state'
    iconClass:  @getState()

  activityMessage: (item) ->
    return if !item
    if item.type is 'create'
      return App.i18n.translateContent('%s created Ticket |%s|', item.created_by.displayName(), item.title)
    else if item.type is 'update'
      return App.i18n.translateContent('%s updated Ticket |%s|', item.created_by.displayName(), item.title)
    else if item.type is 'reminder_reached'
      return App.i18n.translateContent('Pending reminder reached for Ticket |%s|', item.title)
    else if item.type is 'escalation'
      return App.i18n.translateContent('Ticket |%s| is escalated!', item.title)
    else if item.type is 'escalation_warning'
      return App.i18n.translateContent('Ticket |%s| will escalate soon!', item.title)
    return "Unknow action for (#{@objectDisplayName()}/#{item.type}), extend activityMessage() of model."

  # apply macro
  @macro: (params) ->
    for key, content of params.macro
      attributes = key.split('.')
      if attributes[0] is 'ticket'

        # apply tag changes
        if attributes[1] is 'tags'
          tags = content.value.split(',')
          for tag in tags
            if content.operator is 'remove'
              if params.callback && params.callback.tagRemove
                params.callback.tagRemove(tag)
              else
                @tagRemove(params.ticket.id, tag)
            else
              if params.callback && params.callback.tagAdd
                params.callback.tagAdd(tag)
              else
                @tagAdd(params.ticket.id, tag)

        # apply user changes
        else if attributes[1] is 'owner_id'
          if content.pre_condition is 'current_user.id'
            params.ticket[attributes[1]] = App.Session.get('id')
          else
            params.ticket[attributes[1]] = content.value

        # apply direct value changes
        else
          params.ticket[attributes[1]] = content.value

  # check if selector is matching
  @selector: (ticket, selector) ->
    return true if _.isEmpty(selector)

    for objectAttribute, condition of selector
      [objectName, attributeName] = objectAttribute.split('.')

      # there is no article.subject so we take the title instead
      if objectAttribute == 'article.subject' && !ticket['article']['subject']
        objectName    = 'ticket'
        attributeName = 'title'

      # for new articles there is no created_by_id so we set the current user
      # if no id is given
      if objectAttribute == 'article.created_by_id' && !ticket['article']['created_by_id']
        ticket['article']['created_by_id'] = App.Session.get('id')

      if objectName == 'ticket'
        object = ticket
      else
        object = ticket[objectName] || {}

      return false if !@_selectorMatch(object, objectName, attributeName, condition)

    return true

  @_selectorConditionDate: (condition, operator) ->
    return if operator != '+' && operator != '-'

    conditionValue = new Date()
    if condition['range'] == 'minute'
      conditionValue.setTime( eval( conditionValue.getTime() + operator + 60 * 1000 ) )
    else if condition['range'] == 'hour'
      conditionValue.setTime( eval( conditionValue.getTime() + operator + 60 * 60 * 1000 ) )
    else if condition['range'] == 'day'
      conditionValue.setTime( eval( conditionValue.getTime() + operator + 60 * 60 * 24 * 1000 ) )
    else if condition['range'] == 'month'
      conditionValue.setTime( eval( conditionValue.getTime() + operator + 60 * 60 * 30 * 1000 ) )
    else if condition['range'] == 'year'
      conditionValue.setTime( eval( conditionValue.getTime() + operator + 60 * 60 * 365 * 1000 ) )

    conditionValue

  @_selectorMatch: (object, objectName, attributeName, condition) ->
    conditionValue = condition.value
    conditionValue = '' if conditionValue == undefined
    objectValue    = object[attributeName]
    objectValue    = '' if objectValue == undefined

    # take care about pre conditions
    if condition['pre_condition']
      [conditionType, conditionKey] = condition['pre_condition'].split('.')

      if conditionType == 'current_user'
        conditionValue = App.Session.get(conditionKey)
      else if condition['pre_condition'] == 'not_set'
        conditionValue = ''

    # prepare regex for contains conditions
    contains_regex = new RegExp(App.Utils.escapeRegExp(conditionValue.toString()), 'i')

    # move value to array if it is not already
    if !_.isArray(objectValue)
      objectValue = [objectValue]
    # move value to array if it is not already
    if !_.isArray(conditionValue)
      conditionValue = [conditionValue]

    result = false
    for loopObjectKey, loopObjectValue of objectValue
      for loopConditionKey, loopConditionValue of conditionValue
        if condition.operator == 'contains'
          result = true if objectValue.toString().match(contains_regex)
        else if condition.operator == 'contains not'
          result = true if !objectValue.toString().match(contains_regex)
        else if condition.operator == 'contains all'
          result = true
          for loopConditionValue in conditionValue
            if !_.contains(objectValue, loopConditionValue)
              result = false
        else if condition.operator == 'contains one'
          result = false
          for loopConditionValue in conditionValue
            if _.contains(objectValue, loopConditionValue)
              result = true
        else if condition.operator == 'contains all not'
          result = true
          for loopObjectValue in objectValue
            if _.contains(conditionValue, loopObjectValue)
              result = false
        else if condition.operator == 'contains one not'
          result = false
          for loopObjectValue in objectValue
            if !_.contains(conditionValue, loopObjectValue)
              result = true
        else if condition.operator == 'is'
          result = true if objectValue.toString().trim().toLowerCase() is loopConditionValue.toString().trim().toLowerCase()
        else if condition.operator == 'is not'
          result = true if objectValue.toString().trim().toLowerCase() isnt loopConditionValue.toString().trim().toLowerCase()
        else if condition.operator == 'after (absolute)'
          result = true if new Date(objectValue.toString()) > new Date(loopConditionValue.toString())
        else if condition.operator == 'before (absolute)'
          result = true if new Date(objectValue.toString()) < new Date(loopConditionValue.toString())
        else if condition.operator == 'before (relative)'
          loopConditionValue = @_selectorConditionDate(condition, '-')
          result = true if new Date(objectValue.toString()) < new Date(loopConditionValue.toString())
        else if condition.operator == 'within last (relative)'
          loopConditionValue = @_selectorConditionDate(condition, '-')
          result = true if new Date(objectValue.toString()) < new Date() && new Date(objectValue.toString()) > new Date(loopConditionValue.toString())
        else if condition.operator == 'after (relative)'
          loopConditionValue = @_selectorConditionDate(condition, '+')
          result = true if new Date(objectValue.toString()) > new Date(loopConditionValue.toString())
        else if condition.operator == 'within next (relative)'
          loopConditionValue = @_selectorConditionDate(condition, '+')
          result = true if new Date(objectValue.toString()) > new Date() && new Date(objectValue.toString()) < new Date(loopConditionValue.toString())
        else
          throw "Unknown operator: #{condition.operator}"

    result

  editable: (permission = 'change') ->
    user = App.User.current()
    return false if !user?
    return true if user.id is @customer_id
    return true if user.organization_id && @organization_id && user.organization_id is @organization_id
    return false if !@group_id
    group_ids = user.allGroupIds(permission)
    for local_group_id in group_ids
      if local_group_id.toString() is @group_id.toString()
        return true
    false
