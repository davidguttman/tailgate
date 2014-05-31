bean = require 'bean'
api = require './api.coffee'

template = require './playlist.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @items = []

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
  @el.innerHTML = template items: @items
  return this

View::addPath = (path) ->
  api.getPath path, (err, files) =>
    folder =
      name: path.split('/')[-1..][0]
      size: 0
      files: []

    console.log 'folder', folder

    for file in files
      if file.ext in ['mp3', 'm4a']
        file.fullPath = [path, file.name].join '/'
        file.parent = path
        console.log 'file', file
        @items.push file

    @render()
