PlaylistItem = require '../models/playlist_item'

Playlist = Backbone.Collection.extend
  model: PlaylistItem

cache = null

module.exports = ->
  cache = cache or new Playlist