collection = require '../../collections/directory'
template = require '../../templates/directory'

DirectoryView = Backbone.View.extend
  initialize: (@opts) ->
    _.bindAll this

    pathParts = @opts.path.split '/'
    @opts.dirName = pathParts.reverse()[0] or '/'

    @collection = collection @opts.path
    @collection.on 'reset', @render
    @collection.fetch()

  render: ->
    locals = @opts
    
    locals.directories = @collection.directories()
    locals.files = @collection.files()

    @$el.html template locals

module.exports = (opts) ->
  opts = opts or {}
  new DirectoryView opts