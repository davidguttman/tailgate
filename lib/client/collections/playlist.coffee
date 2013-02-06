PlaylistItem = Backbone.Model.extend
  upvote: ->
    path = @get 'path'
    $.get "/api/upvote?path=#{escape path}"
    @set vote: 1

  downvote: ->
    path = @get 'path'
    $.get "/api/downvote?path=#{escape path}"
    @set vote: -1

  clearvote: ->
    path = @get 'path'
    $.get "/api/clearvote?path=#{escape path}"
    @set vote: 0


Playlist = Backbone.Collection.extend
  model: PlaylistItem
  
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