player = require '../../../models/player'
playlist = require '../../../collections/playlist'
template = require '../../../templates/playlist'

Playlist = Backbone.View.extend
  className: 'playlist'

  events:
    'click .list a': 'select'
    'click .list a i.icon-remove-circle': 'removeItem'
  
  initialize: ->
    _.bindAll this

    @collection = playlist()
    @collection.on 'add', @render
    @collection.on 'remove', @render
    @collection.on 'reset', @render

    @player = player()

    @player.on 'change:selected', @render

    @render()

  render: ->
    console.log '@player.selected()', @player.selected()
    @$el.html template
      items: @collection.models
      selected: @player.selected()

  removeItem: (e) ->
    cid = $(e.target).data 'cid'
    @player.remove cid
    e.stopPropagation()

  select: (e) ->
    console.log 'select...'
    cid = $(e.target).data 'cid'
    @player.select cid
    e.preventDefault()

cache = null

module.exports = ->
  cache = cache or new Playlist