window._ = require 'underscore'
window.Backbone = require 'backbone'

globalViews  = require './views/globals'

router       = require 'roto'
routingTable = require './router'

addGlobals = ->
  $main = $('<div/>').addClass('fullpage').attr({'id': 'main', 'role': 'main'})
  $version = $('<div/>').attr({'id': 'app-version'}).html window.VERSION
  
  globalElements = globalViews().elements
  globalElements.push $main
  globalElements.push $version
  
  $('#container').empty()
  $('#container').append globalElements...
  

kickoff = -> 
  addGlobals()
  router $('#main'), routingTable

$(document).ready ->
  
  kickoff()
