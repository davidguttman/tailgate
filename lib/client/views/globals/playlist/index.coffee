playlist = require '../../../collections/playlist'
template = require '../../../templates/playlist'

Playlist = Backbone.View.extend
  className: 'playlist'
  
  initialize: ->
    _.bindAll this
    
    @collection = playlist()
    @collection.on 'add', @render
    
    @render()

  render: ->
    console.log 'rendering...'
    @$el.html template
      items: @collection.models

cache = null

module.exports = ->
  cache = cache or new Playlist