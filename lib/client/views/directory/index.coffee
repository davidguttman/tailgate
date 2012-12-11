collection = require '../../collections/directory'
template = require '../../templates/directory'
playlist = require '../../collections/playlist'

DirectoryView = Backbone.View.extend
  className: 'directory-view'

  events:
    'click tr.mp3 a': 'addToPlaylist'
    'click .add-all a': 'addAllToPlaylist'
    'click .directories th.sort': 'sort'
    'click .files th.sort': 'sort'

  initialize: (@opts) ->
    _.bindAll this

    @sortOpts = 
      files:
        reverse: false
        property: 'name'
      directories:
        reverse: true
        property: 'ctime'

    @collection = collection @opts.path
    @collection.on 'reset', @render
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

    if locals.directories.length is 0
      @$('.directories').hide()
      @$('.files').removeClass('span4').addClass 'span8'

  getLocals: (opts) ->
    locals = _.extend {}, opts
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