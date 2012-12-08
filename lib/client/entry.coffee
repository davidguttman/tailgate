window._ = require 'underscore'
window.Backbone = require 'backbone'

globalViews  = require './views/globals'

router       = require 'roto'
routingTable = require './router'

addGlobals = ->
  $version = $('<div/>').attr({'id': 'app-version'}).html window.VERSION
  
  globalElements = globalViews().elements
  globalElements.push $version
  
  $('#container').empty()
  $('#container').append globalElements...
  

kickoff = -> 
  addGlobals()
  router $('#main'), routingTable

$(document).ready ->
  
  kickoff()
