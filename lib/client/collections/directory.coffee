Entry = require '../models/entry'

Directory = Backbone.Collection.extend
  model: Entry

  initialize: (path) ->
    @path = path

  url: ->
    '/api/get?path='+@path

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

    sorter = sorter or (entry) ->
      (entry.get 'name').toLowerCase()

    _.sortBy filtered, sorter


  files: (sorter) ->
    filtered = @filter (entry) -> 
      (not entry.get 'isDirectory') and (entry.get('ext') is 'mp3')

    sorter = sorter or (entry) ->
      (entry.get 'name').toLowerCase()

    _.sortBy filtered, sorter

module.exports = (path) ->
  new Directory path