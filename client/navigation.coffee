bean = require 'bean'
moment = require 'moment'
hypnotable = require 'hypnotable'
Emitter = require 'wildemitter'
api = require './api.coffee'

template = require './navigation.jade'

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  Emitter.call this
  return this

View.prototype = new Emitter

View::setEvents = ->
  events = [
    ['click', '.add-folder', @addFolder]
  ]

  for event in events
    [type, selector, handler] = event
    bean.on @el, type, selector, handler.bind this

View::renderPath = (path) ->
  @el.innerHTML = template path: path
  listingEl = @el.querySelector '.listing'

  api.getPath path, (err, data) ->
    ht = hypnotable columns
    ht.el.classList.add 'table'
    listingEl.innerHTML = ''
    listingEl.appendChild ht.el

    for item in data
      item.sortName = item.name.toLowerCase()
      item.path = path
      ht.write item

View::addFolder = (evt) ->
  path = unescape evt.currentTarget.dataset.path
  @emit 'add', path

columns = [
  property: '_'
  title: ''
  template: (a, stat) ->
    return '' unless stat.isDirectory
    path = if stat.path is '/' then '' else stat.path
    dirPath = escape(path + '/' + stat.name)
    html = "<button class='btn btn-default add-folder' data-path='#{dirPath}'>"
    html += "<i class='fa fa-plus'></i></button>"
    return html
,
  property: 'sortName'
  title: 'Name'
  template: (sortName, stat) ->
    name = stat.name
    path = if stat.path is '/' then '' else stat.path
    if stat.isDirectory
      url = '#' + escape(path + '/' + name)
    else
      param = [path, name].map(encodeURIComponent).join '/'
      url = '/api/get?path=' + param
    return "<a href='#{url}'>#{name}</a>"
,
  property: 'mtime'
  title: 'Modified'
  template: (t) -> moment(t).fromNow()
]
