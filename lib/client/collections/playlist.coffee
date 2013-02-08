File = require './file'

Playlist = Backbone.Collection.extend
  model: File
  
  storageKey: 'tailgate:playlist'
  
  initialize: ->
    @restore()
    @on 'add', @save
    @on 'remove', @save
    @on 'reset', @save
    @on 'change', @save

  save: ->
    localStorage[@storageKey] = JSON.stringify @toJSON()

  restore: ->
    @reset @getStore()

  getStore: ->
    if localStorage[@storageKey]
      return (JSON.parse localStorage[@storageKey])
    else
      return []

  byCid: (cid) ->
    @find (model) -> model.cid is cid


cache = null

module.exports = ->
  cache = cache or new Playlist