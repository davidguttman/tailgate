Entry = require '../models/entry'

Directory = Backbone.Collection.extend
  model: Entry

  initialize: (opts) ->
    @path = opts.path

  url: ->
    '/api/get?path='+@path

  byCid: (cid) ->
    @find (model) -> model.cid is cid

  parse: (data) ->
    path = @path
    data.map (entry) -> 
      if path is '/'
        entry.path = path + entry.name
      else
        entry.path = path + '/' + entry.name

      if entry.isDirectory
        entry.url = "#/directory/#{JSON.stringify {path: entry.path}}"
      else
        entry.url = "/api/get?path=#{escape entry.path}"
      
      return entry

  directories: (sorter) ->
    filtered = @filter (entry) ->
      entry.get 'isDirectory'

  files: (sorter) ->
    filtered = @filter (entry) -> 
      (not entry.get 'isDirectory') and (entry.get('ext') is 'mp3')

module.exports = (path) ->
  new Directory path:path