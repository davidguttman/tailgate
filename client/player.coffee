bean = require 'bean'
playAudio = require 'play-audio'

template = require './player.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @curFolder = null
  @player = null

  @render()
  return this

View::setEvents = ->
  events = [
    # ['click', '.box', @clickHandler]
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
  @curFileIdx = 0

  @play()

View::play = ->
  file = @curFolder.files[@curFileIdx]
  url = pathToUrl file.fullPath
  if @player
    @player.src url
    @player.play()
  else
    @firstPlay url

View::firstPlay = (url) ->
  @player = playAudio(url, @el).controls().play()
  @player.on 'ended', @onSongEnd.bind(this)

View::onSongEnd = (evt) ->
  console.log 'evt', evt

pathToUrl = (path) ->
  '/api/get?path=' + encodeURIComponent path
