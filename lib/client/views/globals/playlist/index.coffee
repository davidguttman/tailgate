playlist = require '../../../collections/playlist'
template = require '../../../templates/playlist'

Playlist = Backbone.View.extend
  className: 'playlist span2'
  
  initialize: ->
    _.bindAll this

    @collection = playlist()
    @collection.on 'add', @render
    @collection.on 'remove', @render
    
    @render()

  render: ->
    @$el.html template
      items: @collection.models

cache = null

module.exports = ->
  cache = cache or new Playlist