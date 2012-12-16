storageKey = 'tailgate:windowState'

WindowState = Backbone.Model.extend
  defaults:
    playlist: true
    directories: true
    files: true

  initialize: ->
    @restore()
    @on 'change', @store

  store: ->
    localStorage[storageKey] = JSON.stringify @toJSON()

  restore: ->
    @set @getStore()

  getStore: ->
    if localStorage[storageKey]
      return (JSON.parse localStorage[storageKey])
    else
      return []


cache = null

module.exports = ->
  cache = cache or new WindowState