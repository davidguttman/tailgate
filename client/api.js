var URL = require('url')
var jsonist = require('jsonist')
var join = require('path').join

var baseUrl = 'https://music.thhis.com'
var auth = require('./auth').auth

module.exports = {
  getPath: function(path, cb) {
    var url = pathToUrl(path)
    return auth.auth.get(url, function (err, files) {
      if (err) return cb(err)
      cb(null, files.map(function (file) {
        file.path = join(path, file.name)
        return file
      }))
    })
  },

  albumArt: function(query, cb) {
    var url = baseUrl + '/api/art?q=' + encodeURIComponent(query)
    return auth.auth.get(url, cb)
  },

  authenticateUrl: function(url) {
    var parsed = URL.parse(url, true)
    parsed.query._authToken = auth.authToken()
    parsed.search = void 0
    return URL.format(parsed)
  }
}

function pathToUrl (path) {
  return baseUrl + '/api/get?path=' + encodeURIComponent(path)
}
