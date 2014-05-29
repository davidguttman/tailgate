Path = require 'path'
moment = require 'moment'
jsonist = require 'jsonist'
directify = require 'directify'
hypnotable = require 'hypnotable'

baseUrl = window.location.origin

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

onPath = (path) ->
  url = baseUrl + '/api/get?path=' + encodeURIComponent path
  jsonist.get url, (err, data, res) ->
    ht = hypnotable columns
    ht.el.classList.add 'table'
    document.body.innerHTML = ''
    document.body.appendChild ht.el

    if path isnt '/'
      ht.write
        name: '..'
        isDirectory: true
        path: path

    for item in data
      item.sortName = item.name.toLowerCase()
      item.path = path
      ht.write item

routes =
  '/': ->
    path = '/'
    onPath path
  '/.+': ->
    path = window.location.hash.replace /^#/, ''
    nPath = Path.normalize path
    if path isnt nPath
      return window.location.replace '#' + nPath
    onPath nPath

directify routes, document.body

window.location.hash = '/' if window.location.hash is ''
