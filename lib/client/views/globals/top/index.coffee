template = require '../../../templates/top'

Top = Backbone.View.extend
  className: 'navbar navbar-inverse navbar-fixed-top'
  
  initialize: ->
    @render()

  render: ->
    @$el.html template()

module.exports = ->
  new Top