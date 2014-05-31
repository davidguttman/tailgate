jsonist = require 'jsonist'
baseUrl = window.location.origin

module.exports =
  getPath: (path, cb) ->
    url = pathToUrl path
    jsonist.get url, cb

pathToUrl = (path) ->
  baseUrl + '/api/get?path=' + encodeURIComponent path
