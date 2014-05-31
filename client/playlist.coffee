_ = require 'underscore'
bean = require 'bean'
Emitter = require 'wildemitter'
api = require './api.coffee'

template = require './playlist.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @items = []

  @render()
  Emitter.call this
  return this

View.prototype = new Emitter

View::setEvents = ->
  events = [
    ['click', '.media a', @playItem]
  ]

  for event in events
    [type, selector, handler] = event
    bean.on @el, type, selector, handler.bind this

View::render = ->
  @el.innerHTML = template items: @items
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
  @emit 'play', folder
