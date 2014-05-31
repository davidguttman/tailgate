Path = require 'path'
directify = require 'directify'
nav = require('./navigation.coffee')()
playlist = require('./playlist.coffee')()
player = require('./player.coffee')()

template = require './index.jade'

document.body.innerHTML = template()

explorer = document.querySelector '.explorer'
explorer.appendChild nav.el

cPlaylist = document.querySelector '.playlist'
cPlaylist.appendChild playlist.el

cPlayer = document.querySelector '.player'
cPlayer.appendChild player.el

nav.on 'add', (path) ->
  playlist.addPath path

playlist.on 'play', (folder) ->
  player.playFolder folder

routes =
  '/': ->
    path = '/'
    nav.renderPath path
  '/.+': ->
    path = window.location.hash.replace /^#/, ''
    nPath = Path.normalize path
    if path isnt nPath
      return window.location.replace '#' + nPath
    if path isnt unescape(path)
      return window.location.replace '#' + unescape(path)
    nav.renderPath nPath

directify routes, document.body

window.location.hash = '/' if window.location.hash is ''
