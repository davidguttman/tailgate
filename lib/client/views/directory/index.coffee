windowState = require '../../models/window_state'

collection = require '../../collections/directory'
template = require './index.jade'
playlist = require '../../collections/playlist'

DirectoryView = Backbone.View.extend
  className: 'directory-view'

  events:
    'click .mp3 a': 'addToPlaylist'
    'click .add-all a': 'addAllToPlaylist'

    'click .directories .window-collapse': 'collapseDirectories'
    'click .directories .window-expand': 'expandDirectories'

    'click .files .window-collapse': 'collapseFiles'
    'click .files .window-expand': 'expandFiles'

  initialize: (@opts) ->
    _.bindAll this

    @windowState = windowState()
    @windowState.on 'change:directories', @render
    @windowState.on 'change:files', @render

    @sortOpts = 
      files:
        reverse: false
        property: 'name'
      directories:
        reverse: true
        property: 'ctime'

    @collection = collection @opts.path
    @collection.on 'reset', @render
    @collection.on 'change', @render
    @collection.fetch()

    @playlist = playlist()

  render: ->
    locals = @getLocals @opts
    
    sortOpts = @sortOpts
    locals.files = _.sortBy locals.files, (file) ->
      (file.get sortOpts.files.property).toLowerCase()
    locals.files.reverse() if sortOpts.files.reverse

    locals.directories = _.sortBy locals.directories, (dir) ->
      (dir.get sortOpts.directories.property).toLowerCase()
    locals.directories.reverse() if sortOpts.directories.reverse

    @$el.html template locals
    
    new List @$('.directory-list')[0], valueNames: ['name', 'time']
    new List @$('.files-list')[0], valueNames: ['name', 'time']

  getLocals: (opts) ->
    locals = _.extend {}, opts

    locals.filesActive = @windowState.get 'files'
    locals.directoriesActive = @windowState.get 'directories'

    pathParts = locals.path.split '/'
    
    if pathParts.length < 2
      locals.upPath = '/'
    else
      locals.upPath = pathParts[0..-2].join '/'

    locals.dirName = pathParts.reverse()[0] or '/'
  
    if locals.path is '' or locals.path is '/'
      locals.upLink = null
    else
      locals.upLink = @pathToUrl locals.upPath
    
    locals.directories = @collection.directories()    
    locals.files = @collection.files()

    return locals

  sort: (e) ->
    type = $(e.target).data 'sort-type'
    property = $(e.target).data 'sort-property'
    
    @sortOpts[type].property ?= property
    changed = property isnt @sortOpts[type].property

    @sortOpts[type].property = property
    @sortOpts[type].reverse = not @sortOpts[type].reverse unless changed
    
    @render()


  addFromElement: (el) ->
    $el = $(el)
    cid = $el.data 'cid'
    item = @collection.byCid cid
    
    @playlist.add item

  addAllToPlaylist: ->
    addFromElement = @addFromElement
    @$('li.mp3 a').each (i, el) ->
      addFromElement el

  addToPlaylist: (event) ->
    @addFromElement event.target
    event.preventDefault()

  pathToUrl: (path) ->
    path = '/' if path is ''
    "#/directory/#{JSON.stringify {path: path}}"

  collapseFiles: -> @windowState.set 'files': false

  expandFiles: -> @windowState.set 'files': true

  collapseDirectories: -> @windowState.set 'directories': false

  expandDirectories: -> @windowState.set 'directories': true


module.exports = (opts) ->
  opts = opts or {}
  new DirectoryView opts