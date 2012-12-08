PlaylistItem = require '../models/playlist_item'

Playlist = Backbone.Collection.extend
  model: PlaylistItem
  
  storageKey: 'tailgate:playlist'
  
  initialize: ->
    @restore()
    @on 'add', @save
    @on 'remove', @save
    @on 'reset', @save

  save: ->
    localStorage[@storageKey] = JSON.stringify @toJSON()

  restore: ->
    @reset @getStore()

  getStore: ->
    if localStorage[@storageKey]
      return (JSON.parse localStorage[@storageKey])
    else
      return []


cache = null

module.exports = ->
  cache = cache or new Playlist