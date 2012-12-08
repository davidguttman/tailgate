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

    @render()

  render: ->
    @$el.html template
      items: @collection.models

  prev: ->
    console.log 'prev'

  play: ->
    console.log 'play'

  pause: ->
    console.log 'pause'

  clear: ->
    forReals = confirm 'Clear playlist?'
    console.log 'forReals', forReals

  next: ->
    console.log 'next'




cache = null

module.exports = ->
  cache = cache or new Playlist