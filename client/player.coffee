id3 = require 'id3js'
bean = require 'bean'
Emitter = require 'wildemitter'
playAudio = require 'play-audio'

styles = require './player.scss'
template = require './player.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @curFolder = null
  @curPlaying = null
  @player = null

  @playing = false

  @render()
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

View::playFolder = (folder) ->
  return if @curFolder is folder

  @curFolder = folder

  @loadSong 0

View::loadSong = (idx) ->
  @curFileIdx = idx
  file = @curFolder.files[idx]

  if not file
    return @emit 'ended', @curFolder

  url = pathToUrl file.fullPath

  if @player
    @player.src url
  else
    @firstPlay url

  @play()
  @showInfo url

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

View::showInfo = (url) ->
  elArt = @el.querySelector '.album-art'
  elTitle = @el.querySelector '.track-info .title'
  elArtist = @el.querySelector '.track-info .artist'

  elTitle.innerHTML = ''
  elArtist.innerHTML = ''
  elArt.innerHTML = ''

  if @curFolder.cover
    elArt.innerHTML = "<img src='#{pathToUrl @curFolder.cover.fullPath}' />"

  id3 url, (err, tags) ->
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
  progress = (audio.currentTime / audio.duration)
  elProgress.style.width = (progress * 100) + '%'

pathToUrl = (path) ->
  '/api/get?path=' + encodeURIComponent path
