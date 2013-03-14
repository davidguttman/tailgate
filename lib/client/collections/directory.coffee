File = require './file'

Directory = Backbone.Collection.extend
  model: File

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
        entry.url = "/api/get?path=#{encodeURIComponent entry.path}"
      
      return entry

  directories: (sorter) ->
    filtered = @filter (entry) ->
      entry.get 'isDirectory'

  files: (sorter) ->
    filtered = @filter (entry) -> 
      isFile = not entry.get 'isDirectory'
      ext = entry.get 'ext'
      audioExts = 'mp3 m4a ogg'.split ' '
      isAudio = ext in audioExts
      isFile and isAudio

module.exports = (path) ->
  new Directory path:path