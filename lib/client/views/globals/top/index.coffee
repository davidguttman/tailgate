template = require '../../../templates/top'

Top = Backbone.View.extend
  className: 'navbar navbar-inverse affix'
  
  initialize: ->
    @render()

  render: ->
    @$el.html template()

module.exports = ->
  new Top