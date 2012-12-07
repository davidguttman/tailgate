template = require '../../templates/systems/load'

module.exports = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    @$el.html template()
