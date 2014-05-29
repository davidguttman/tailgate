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
    if stat.isDirectory
      path = if stat.path is '/' then '' else stat.path
      url = '#' + path + '/' + name
      return "<a href='#{url}'>#{name}</a>"
    else
      return name
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
    onPath path

directify routes, document.body

window.location.hash = '/' if window.location.hash is ''
