Path = require 'path'
FastClick = require 'fastclick'
directify = require 'directify'
nav = require('./navigation.coffee')()
playlist = require('./playlist.coffee')()
player = require('./player.coffee')()
auth = require './auth.coffee'

db = require './db.coffee'
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

player.on 'ended', ->
  playlist.playNext()

routes =
  '/login': auth.routes.login
  '/signup': auth.routes.signup
  '/logout': auth.routes.logout
  '/confirm/.+': auth.routes.confirm
  '/change-password/.+': auth.routes.changePassword
  '/change-password-request': auth.routes.changePasswordRequest

  '/_reset': -> db.reset()

  '/': ->
    return window.location.hash = '/login' unless auth.auth.authToken()

    path = '/'
    nav.renderPath path

  '/.+': ->
    return window.location.hash = '/login' unless auth.auth.authToken()

    path = window.location.hash.replace /^#/, ''
    nPath = Path.normalize path
    if path isnt nPath
      return window.location.replace '#' + nPath
    if path isnt unescape(path)
      return window.location.replace '#' + unescape(path)
    nav.renderPath nPath

directify routes, document.body

window.location.hash = '/' if window.location.hash is ''

window.addEventListener 'load', ->
  new FastClick document.body
, false
