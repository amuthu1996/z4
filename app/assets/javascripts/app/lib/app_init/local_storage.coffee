class App.LocalStorage
  _instance = undefined # Must be declared here to force the closure on the class

  @set: (key, value, user_id) ->
    if _instance == undefined
      _instance ?= new _storeSingleton
    _instance.set(key, value, user_id)

  @get: (key, user_id) ->
    if _instance == undefined
      _instance ?= new _storeSingleton
    _instance.get(key, user_id)

  @delete: (key, user_id) ->
    if _instance == undefined
      _instance ?= new _storeSingleton
    _instance.delete(key, user_id)

  @clear: ->
    if _instance == undefined
      _instance ?= new _storeSingleton
    _instance.clear()

  @list: ->
    if _instance == undefined
      _instance ?= new _storeSingleton
    _instance.list()

  @usage: ->
    if _instance == undefined
      _instance ?= new _storeSingleton
    _instance.usage()

# The actual Singleton class
class _storeSingleton
  constructor: ->

  # write to local storage
  set: (key, value, user_id) ->
    try
      if user_id
        key = "personal::#{user_id}::#{key}"
      localStorage.setItem(key, JSON.stringify(value))
    catch e
      App.Log.error 'App.LocalStorage', 'Local storage error!', e

  # get item
  get: (key, user_id) ->
    if user_id
      key = "personal::#{user_id}::#{key}"
    value = localStorage.getItem(key)
    return if !value
    JSON.parse(value)

  # delete item
  delete: (key, user_id) ->
    if user_id
      key = "personal::#{user_id}::#{key}"
    localStorage.removeItem(key)

  # clear local storage
  clear: ->
    localStorage.clear()

  # return list of all keys
  list: ->
    window.localStorage

  # get usage
  usage: ->
    total = ''
    for key of window.localStorage
      value = localStorage.getItem(key)
      if _.isString(value)
        total += value
    byteLength(total)
