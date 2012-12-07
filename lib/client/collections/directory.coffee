Directory = Backbone.Collection.extend
  initialize: (path) ->
    @path = path

  url: ->
    '/api/get?path='+@path

module.exports = (path) ->
  new Directory path