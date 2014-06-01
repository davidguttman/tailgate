id3 = require 'id3js'
bean = require 'bean'
Emitter = require 'wildemitter'
playAudio = require 'play-audio'

db = require './db.coffee'
styles = require './player.scss'
template = require './player.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @curFolder = null
  @curFileIdx = null
  @player = null
  @curTime = 0

  @playing = false

  @saveInterval = 3000
  @lastSave = Date.now()

  @render()
  @loadState()

  Emitter.call this
  return this

View.prototype = new Emitter

View::setEvents = ->
  events = [
    ['click', '.player-control .play', @play]
    ['click', '.player-control .pause', @pause]
    ['click', '.player-control .next', @playNextSong]
    ['click', '.player-control .prev', @playPrevSong]
  ]

  for event in events
    [type, selector, handler] = event
    bean.on @el, type, selector, handler.bind this

View::render = ->
  @el.innerHTML = template()
  return this

View::playFolder = (folder, songIdx = 0, time = 0) ->
  return if @curFolder is folder

  @curFolder = folder

  @loadSong songIdx, time

View::loadSong = (idx, time = 0) ->
  @curFileIdx = idx
  file = @curFolder.files[idx]

  if not file
    return @emit 'ended', @curFolder

  url = pathToUrl file.fullPath
  file.url = url

  if @player
    @player.src url
  else
    @firstPlay url

  @play()
  @setTime time
  @showInfo file

View::setTime = (time) ->
  called = false
  @player.on 'durationchange', =>
    return if called
    @player.currentTime time
    called = true

View::play = ->
  return @pause() if @playing

  @player.play()
  @playing = true
  @el.querySelector('.player-control .play').classList.add 'hide'
  @el.querySelector('.player-control .pause').classList.remove 'hide'

View::pause = ->
  return @play() if not @playing

  @player.pause()
  @playing = false
  @el.querySelector('.player-control .pause').classList.add 'hide'
  @el.querySelector('.player-control .play').classList.remove 'hide'

View::showInfo = (file) ->
  elArt = @el.querySelector '.album-art'
  elTitle = @el.querySelector '.track-info .title'
  elArtist = @el.querySelector '.track-info .artist'

  elTitle.innerHTML = file.name.replace ".#{file.ext}", ''
  elArtist.innerHTML = ''
  elArt.innerHTML = ''

  if @curFolder.cover
    elArt.innerHTML = "<img src='#{pathToUrl @curFolder.cover.fullPath}' />"

  id3 file.url, (err, tags) ->
    elTitle.innerHTML = tags.title if tags.title
    elArtist.innerHTML = 'by ' + tags.artist if tags.artist

View::firstPlay = (url) ->
  @player = playAudio(url, @el)
  # @player.volume 0
  # @player.controls()
  @player.on 'ended', @onSongEnd.bind(this)
  @player.on 'timeupdate', @onProgress.bind(this)

View::playNextSong = ->
  @playing = false
  @loadSong @curFileIdx + 1

View::playPrevSong = ->
  @playing = false
  if @curFileIdx > 0
    @loadSong @curFileIdx - 1

View::onSongEnd = (evt) ->
  @playing = false
  @playNextSong()

View::onProgress = (evt) ->
  audio = evt.srcElement
  elProgress = @el.querySelector('.track-progress')
  @curTime = audio.currentTime
  progress = (@curTime / audio.duration)
  elProgress.style.width = (progress * 100) + '%'
  @saveState()

View::saveState = ->
  now = Date.now()
  return unless now - @lastSave > @saveInterval
  @lastSave = now

  key = ['player', '_state'].join '\xff'
  state =
    curFolder: @curFolder
    curFileIdx: @curFileIdx
    curTime: @curTime

  db.put key, state

View::loadState = ->

  key = ['player', '_state'].join '\xff'

  db.get key, (err, state) =>
    if state
      @playFolder state.curFolder, state.curFileIdx, state.curTime

pathToUrl = (path) ->
  '/api/get?path=' + encodeURIComponent path
