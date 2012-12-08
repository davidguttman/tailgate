collection = require '../../collections/directory'
template = require '../../templates/directory'
playlist = require '../../collections/playlist'

DirectoryView = Backbone.View.extend
  className: 'directory-view'

  events:
    'click tr.mp3 a': 'addToPlaylist'
    'click .add-all a': 'addAllToPlaylist'
    'click .directories th.sort': 'sortDirectories'
    'click .files th.sort': 'sortFiles'

  initialize: (@opts) ->
    _.bindAll this

    @path = @opts.path

    pathParts = @opts.path.split '/'
    
    if pathParts.length < 2
      @upPath = '/'
    else
      @upPath = pathParts[0..-2].join '/'

    @opts.dirName = pathParts.reverse()[0] or '/'

    @fileSortReverse = false
    @directorySortReverse = false

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

    locals.directories = @collection.directories @directorySorter
    locals.directories.reverse() if @directorySortReverse

    locals.files = @collection.files @fileSorter
    locals.files.reverse() if @fileSortReverse

    @$el.html template locals

    if locals.directories.length is 0
      @$('.directories').hide()
      @$('.files').removeClass('span5').addClass 'span10'

  sortFiles: (e) ->
    sortProperty = $(e.target).data 'sort'
    @fileSortProperty ?= sortProperty
    changed = sortProperty isnt @fileSortProperty
    @fileSortProperty = sortProperty
    @fileSortReverse = not @fileSortReverse unless changed
    @fileSorter = (file) ->
      (file.get sortProperty).toLowerCase()
    @render()

  sortDirectories: (e) ->
    sortProperty = $(e.target).data 'sort'
    @directorySortProperty ?= sortProperty
    changed = sortProperty isnt @directorySortProperty
    @directorySortProperty = sortProperty
    @directorySortReverse = not @directorySortReverse unless changed
    @directorySorter = (dir) ->
      (dir.get sortProperty).toLowerCase()
    @render()

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