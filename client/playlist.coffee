_ = require 'underscore'
bean = require 'bean'
moment = require 'moment'
Emitter = require 'wildemitter'

db = require './db.coffee'
api = require './api.coffee'

styles = require './playlist.scss'
template = require './playlist.jade'
loadPlaylistTemplate = require './load-playlist.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @name = 'Playlist'
  @items = []
  @curPlaying = {}

  @load '_auto', => @render()
  Emitter.call this
  return this

View.prototype = new Emitter

View::setEvents = ->
  events = [
    ['click', 'a.item', @playItem]
    ['click', '.actions .clear', @clearPlaylist]
    ['click', '.actions .save', @savePlaylist]
    ['click', '.actions .load', @renderLoadPlaylist]

    ['click', '.actions .cancel', @render]
    ['click', 'a.load-playlist', @loadPlaylist]
  ]

  for event in events
    [type, selector, handler] = event
    bean.on @el, type, selector, handler.bind this

View::render = ->
  @save()
  @el.innerHTML = template
    items: @items
    curPlaying: @curPlaying

  return this

View::renderLoadPlaylist = ->
  @getSavedPlaylists (err, playlists) =>
    @el.innerHTML = loadPlaylistTemplate playlists: playlists

  return this

View::addPath = (path) ->
  api.getPath path, (err, files) =>
    folder =
      name: path.split('/')[-1..][0]
      path: path
      size: 0
      files: []

    for file in files
      file.fullPath = [path, file.name].join '/'
      file.parent = path

      if file.ext in ['mp3', 'm4a']
        folder.files.push file
        folder.size += file.size

      if file.ext in ['png', 'jpg']
        folder.cover = file

    @items.push folder

    @render()

View::playItem = (evt) ->
  path = evt.currentTarget.dataset.path
  folder = _.find @items, (item) -> item.path is path
  @curPlaying = folder
  @emit 'play', @curPlaying
  @render()

View::playNext = ->
  curIndex = null
  for folder, i in @items
    if folder.path is @curPlaying.path
      curIndex = i

  nextIndex = curIndex + 1

  if @items[nextIndex]
    @curPlaying = @items[nextIndex]
  else if @items[0]
    @curPlaying = @items[0]

  @emit 'play', @curPlaying if @curPlaying
  @render()

View::clearPlaylist = ->
  name = '_prev_' + Date.now()
  @save name
  @items = []
  @curPlaying = {}
  @render()

View::savePlaylist = ->
  name = prompt 'Playlist Name?'
  if name is '' or name.match /^_/
    return @savePlaylist()
  @save name

View::loadPlaylist = (evt) ->
  name = evt.currentTarget.dataset.name
  @load name, => @render()

View::formatSavedPlaylist = (playlist) ->
  {name, items} = playlist

  name ?= 'Unnamed Playlist'
  return null if name.match /^_auto/

  if name.match /^_prev_/
    type = 'prev'
    time = parseFloat name.split('_prev_')[1]

    date = moment(time).format 'dddd, MMM Do hA'
    name = date

  n = items.length - 2

  description = ' with '
  description += items[0].name if items[0]
  description += ', ' + items[1].name if items[1]
  description += ", and #{n} others" if n > 0

  playlist.displayName = name
  playlist.description = description
  playlist.type = type
  return playlist

View::getSavedPlaylists = (cb) ->
  rs = db.createReadStream
    start: 'playlist'
    end: 'playlist' + '\xff\xff'

  playlists = []
  prevs = []

  rs.on 'data', ({key, value}) =>
    playlist = @formatSavedPlaylist value

    if playlist
      if playlist.type is 'prev'
        prevs.push playlist
      else
        playlists.push playlist

  rs.on 'error', cb

  rs.on 'end', ->
    playlists.push prev for prev in prevs[-4..].reverse()
    cb null, playlists

View::load = (name = '_auto', cb = ->) ->
  key = ['playlist', name].join '\xff'
  db.get key, (err, playlist = {}) =>
    if playlist.name and not playlist.name.match /^_/
      @name = playlist.name
    else
      @name = 'Playlist'

    @items = playlist.items if playlist.items
    @curPlaying = playlist.curPlaying if playlist.curPlaying
    cb()

View::save = (name = '_auto', cb = ->) ->
  state =
    name: name
    items: @items
    curPlaying: @curPlaying

  key = ['playlist', name].join '\xff'
  db.put key, state, cb
