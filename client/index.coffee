Path = require 'path'
directify = require 'directify'
nav = require('./navigation.coffee')()

template = require './index.jade'

document.body.innerHTML = template()

explorer = document.querySelector '.explorer'
explorer.appendChild nav.el

routes =
  '/': ->
    path = '/'
    nav.renderPath path
  '/.+': ->
    path = window.location.hash.replace /^#/, ''
    nPath = Path.normalize path
    if path isnt nPath
      return window.location.replace '#' + nPath
    nav.renderPath nPath

directify routes, document.body

window.location.hash = '/' if window.location.hash is ''
