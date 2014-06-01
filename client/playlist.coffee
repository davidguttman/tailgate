_ = require 'underscore'
bean = require 'bean'
Emitter = require 'wildemitter'

db = require './db.coffee'
api = require './api.coffee'

styles = require './playlist.scss'
template = require './playlist.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @items = []
  @curPlaying = {}

  @load '_auto', => @render()
  Emitter.call this
  return this

View.prototype = new Emitter

View::setEvents = ->
  events = [
    ['click', '.media a', @playItem]
    ['click', '.actions .clear', @clearPlaylist]
    ['click', '.actions .save', @savePlaylist]
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

View::load = (name = '_auto', cb = ->) ->
  key = ['playlist', name].join '\xff'
  db.get key, (err, playlist = {}) =>
    @items = playlist.items if playlist.items
    @curPlaying = playlist.curPlaying if playlist.curPlaying
    cb()

View::save = (name = '_auto', cb = ->) ->
  state =
    items: @items
    curPlaying: @curPlaying

  key = ['playlist', name].join '\xff'
  db.put key, state, cb
