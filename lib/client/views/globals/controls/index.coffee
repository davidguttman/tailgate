template = require '../../../templates/controls'

player = require './player'
windowManager = require './window_manager'

Controls = Backbone.View.extend
  className: 'navbar navbar-inverse affix'
  
  initialize: ->
    @player = player()
    @windowManager = windowManager()
    
    @render()

  render: ->
    @$el.html template()
    @$('.container').append @player.el
    @$('.container').append @windowManager.el


module.exports = ->
  new Controls