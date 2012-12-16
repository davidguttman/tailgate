template = require '../../../templates/controls'

player = require './player'

Controls = Backbone.View.extend
  className: 'navbar navbar-inverse affix'
  
  initialize: ->
    @player = player()
    @render()

  render: ->
    @$el.html template()
    @$('.container').append @player.el


module.exports = ->
  new Controls