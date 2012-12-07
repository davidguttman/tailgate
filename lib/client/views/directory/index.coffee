collection = require '../../collections/directory'
template = require '../../templates/directory'

DirectoryView = Backbone.View.extend
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

  render: ->
    locals = @opts
  
    if @path is '' or @path is '/'
      locals.upLink = null
    else
      locals.upLink = @pathToLink @upPath

    locals.directories = @collection.directories()
    locals.files = @collection.files()
    locals.pathToLink = @pathToLink

    @$el.html template locals

  pathToLink: (path) ->
    console.log 'path', path
    path = '/' if path is ''
    "#/directory/#{JSON.stringify {path: path}}"


module.exports = (opts) ->
  opts = opts or {}
  new DirectoryView opts