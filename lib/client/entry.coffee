Fastclick    = require 'fastclick'
globalViews  = require './views/globals'

router       = require 'directify'
routingTable = require './router'

addGlobals = ->
  $version = $('<div/>').attr({'id': 'app-version'}).html window.VERSION
  
  globalElements = globalViews().elements
  globalElements.push $version
  
  $('#container').empty()
  $('#container').append globalElements...
  

kickoff = -> 
  addGlobals()
  router routingTable, $('#main')
  if window.location.hash is ''
    window.location.hash = '/'

$(document).ready ->
  new Fastclick document.body

  soundManager.setup
    url: '/swf'
    preferFlash: false
    # useHTML5Audio: true
    onready: kickoff