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

pathToUrl = (path) ->
  baseUrl + '/api/get?path=' + encodeURIComponent path
