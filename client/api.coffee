URL = require 'url'
jsonist = require 'jsonist'
baseUrl = 'https://music.thhis.com'
{auth} = require './auth.coffee'

module.exports =
  getPath: (path, cb) ->
    url = pathToUrl path
    auth.auth.get url, cb

  albumArt: (query, cb) ->
    url = baseUrl + '/api/art?q=' + encodeURIComponent query
    auth.auth.get url, cb

  authenticateUrl: (url) ->
    parsed = URL.parse url, true
    parsed.query._authToken = auth.authToken()
    parsed.search = undefined
    URL.format parsed

pathToUrl = (path) ->
  baseUrl + '/api/get?path=' + encodeURIComponent path
