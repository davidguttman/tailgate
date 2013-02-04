windowState = require '../../../models/window_state'
player = require '../../../models/player'
playlist = require '../../../collections/playlist'
template = require './playlist.jade'

Playlist = Backbone.View.extend
  className: 'playlist'

  events:
    'click .list a': 'select'
    'click .list a i.icon-remove-circle': 'removeItem'

    'click .window-collapse': 'collapse'
    'click .window-expand': 'expand'
  
  initialize: ->
    _.bindAll this

    @windowState = windowState()
    @windowState.on 'change:playlist', @render

    @collection = playlist()
    @collection.on 'add', @render
    @collection.on 'remove', @render
    @collection.on 'reset', @render

    @player = player()

    @player.on 'change:selected', @render

    @render()

  render: ->
    active = @windowState.get 'playlist'

    @$el.html template
      items: @collection.models
      selected: @player.selected()
      active: active

  removeItem: (e) ->
    cid = $(e.target).data 'cid'
    @player.remove cid
    e.stopPropagation()

  select: (e) ->
    console.log 'select...'
    cid = $(e.target).data 'cid'
    @player.select cid
    e.preventDefault()

  collapse: ->
    @windowState.set 'playlist': false

  expand: ->
    @windowState.set 'playlist': true

cache = null

module.exports = ->
  cache = cache or new Playlist