jsonist = require 'jsonist'
baseUrl = window.location.origin

module.exports =
  getPath: (path, cb) ->
    url = pathToUrl path
    jsonist.get url, cb

  getCode: (email, cb) ->
    url = baseUrl + '/get-code'
    jsonist.post url, {email: email}, cb

  login: (email, code, cb) ->
    url = baseUrl + '/login'
    jsonist.post url, {email: email, code: code}, cb

  albumArt: (query, cb) ->
    url = baseUrl + '/api/art?q=' + encodeURIComponent query
    jsonist.get url, cb

pathToUrl = (path) ->
  baseUrl + '/api/get?path=' + encodeURIComponent path
