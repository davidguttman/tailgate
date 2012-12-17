template = require '../../../templates/controls'
player = require '../../../models/player'

playerControls = require './player'
windowManager = require './window_manager'

Controls = Backbone.View.extend
  className: 'navbar navbar-inverse affix'
  
  initialize: ->
    _.bindAll this

    @playerControls = playerControls()
    @windowManager = windowManager()
    
    @player = player()
    @player.on 'change:progress', @updateProgress

    @render()

  render: ->
    @$el.html template()
    @$('.container').append @playerControls.el
    @$('.container').append @windowManager.el

  updateProgress: ->
    r = @player.get "progress"
    @$('.song-progress .fill').width "#{r*100}%"


module.exports = ->
  new Controls