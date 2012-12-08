collection = require '../../collections/directory'
template = require '../../templates/directory'
playlist = require '../../collections/playlist'

DirectoryView = Backbone.View.extend
  className: 'directory-view'

  events:
    'click tr.mp3 a': 'addToPlaylist'
    'click .add-all a': 'addAllToPlaylist'

  initialize: (@opts) ->
    _.bindAll this

    @path = @opts.path

    pathParts = @opts.path.split '/'
    
    if pathParts.length < 2
      @upPath = '/'
    else
      @upPath = pathParts[0..-2].join '/'

    @opts.dirName = pathParts.reverse()[0] or '/'

    @collection = collection @opts.path
    @collection.on 'reset', @render
    @collection.fetch()

    @playlist = playlist()

  render: ->
    locals = @opts
  
    if @path is '' or @path is '/'
      locals.upLink = null
    else
      locals.upLink = @pathToUrl @upPath

    locals.directories = @collection.directories()
    locals.files = @collection.files()

    @$el.html template locals

    if locals.directories.length is 0
      @$('.directories').hide()
      @$('.files').removeClass('span5').addClass 'span10'

  addFromElement: (el) ->
    $el = $(el)
    name = $el.data "name"
    url = $el.data "url"

    @playlist.add
      name: name
      url: url

  addAllToPlaylist: ->
    addFromElement = @addFromElement
    @$('tr.mp3 a').each (i, el) ->
      addFromElement el

  addToPlaylist: (event) ->
    @addFromElement event.target
    event.preventDefault()

  pathToUrl: (path) ->
    path = '/' if path is ''
    "#/directory/#{JSON.stringify {path: path}}"


module.exports = (opts) ->
  opts = opts or {}
  new DirectoryView opts