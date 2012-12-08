player = require '../../../models/player'
playlist = require '../../../collections/playlist'
template = require '../../../templates/playlist'

Playlist = Backbone.View.extend
  className: 'playlist span2'

  events:
    'click i.icon-step-backward': 'prev'
    'click i.icon-play': 'play'
    'click i.icon-pause': 'pause'
    'click i.icon-remove-sign': 'clear'
    'click i.icon-step-forward': 'next'
  
  initialize: ->
    _.bindAll this

    @collection = playlist()
    @collection.on 'add', @render
    @collection.on 'remove', @render

    @player = player @collection
    @player.on 'change', @render

    @render()

  render: ->
    console.log '@player.selected()', @player.selected()
    @$el.html template
      items: @collection.models
      selected: @player.selected()

  prev: ->
    @player.prev()

  play: ->
    @player.play()

  pause: ->
    console.log 'pause'

  clear: ->
    forReals = confirm 'Clear playlist?'
    console.log 'forReals', forReals

  next: ->
    @player.next()




cache = null

module.exports = ->
  cache = cache or new Playlist