template = require '../../../templates/top'
auth = require '../../../helpers/auth'

Top = Backbone.View.extend
  className: 'navbar navbar-inverse navbar-fixed-top'
  events:
    'click a.login': 'login'
  
  initialize: ->
    @render()

  render: ->
    @$el.html template()

  login: ->
    navigator.id.get auth

module.exports = ->
  new Top