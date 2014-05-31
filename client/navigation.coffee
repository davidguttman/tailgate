bean = require 'bean'
moment = require 'moment'
jsonist = require 'jsonist'
hypnotable = require 'hypnotable'

template = require './navigation.jade'

baseUrl = window.location.origin

module.exports = -> new View arguments...

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  return this

View::setEvents = ->
  events = [
    # ['click', '.box', @clickHandler]
  ]

  for event in events
    [type, selector, handler] = event
    bean.on @el, type, selector, handler.bind this

View::renderPath = (path) ->
  @el.innerHTML = template path: path
  listingEl = @el.querySelector '.listing'

  url = pathToUrl path
  jsonist.get url, (err, data, res) ->
    ht = hypnotable columns
    ht.el.classList.add 'table'
    listingEl.innerHTML = ''
    listingEl.appendChild ht.el

    for item in data
      item.sortName = item.name.toLowerCase()
      item.path = path
      ht.write item

pathToUrl = (path) ->
  baseUrl + '/api/get?path=' + encodeURIComponent path

columns = [
  property: 'sortName'
  title: 'Name'
  template: (sortName, stat) ->
    name = stat.name
    path = if stat.path is '/' then '' else stat.path
    if stat.isDirectory
      url = '#' + path + '/' + name
    else
      param = [path, name].map(encodeURIComponent).join '/'
      url = '/api/get?path=' + param
    return "<a href='#{url}'>#{name}</a>"
,
  property: 'mtime'
  title: 'Modified'
  template: (t) -> moment(t).fromNow()
]
