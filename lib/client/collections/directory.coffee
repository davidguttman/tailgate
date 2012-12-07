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
      entry.path = path + '/' + entry.name
      return entry

  directories: ->
    filtered = @filter (entry) ->
      entry.get 'isDirectory'
    _.sortBy filtered, (entry) ->
      (entry.get 'name').toLowerCase()


  files: ->
    filtered = @filter (entry) -> 
      not entry.get 'isDirectory'
    _.sortBy filtered, (entry) ->
      (entry.get 'name').toLowerCase()

module.exports = (path) ->
  new Directory path