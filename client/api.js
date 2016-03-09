var URL = require('url')
var jsonist = require('jsonist')
var join = require('path').join
var xtend = require('xtend')

var baseUrl = 'https://music.thhis.com'
var auth = require('./auth').auth

module.exports = {
  getPath: function(path, cb) {
    var url = pathToUrl(path)
    return auth.auth.get(url, function (err, files) {
      if (err) return cb(err)
      cb(null, files.map(function (file) {
        file.path = join(path, file.name)
        if (file.isDirectory) { file = xtend(file, parseName(file.name)) }
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
  },

  parseName: parseName
}

function pathToUrl (path) {
  return baseUrl + '/api/get?path=' + encodeURIComponent(path)
}

function parseName (name) {
  if (name[0] === '/') name = name.slice(1)

  var metaStart = name.length
  for (var i = 0; i < name.length; i++) {
    if (name[i] === '(' || name[i] === '[' ) {
      metaStart = i
      break
    }
  }

  var artistAlbum = name.slice(0, metaStart)
  var meta = name.slice(metaStart)

  var artist = (artistAlbum.split(' - ')[0] || '').replace(/_/g, ' ')
  var album = (artistAlbum.split(' - ')[1] || '').replace(/_/g, ' ')
  var year = (meta.match(/\d{4}/) || [])[0]

  if (!artist) {
    artist = name
    album = ''
    meta = ''
  }

  if (artist === 'VA') artist = 'Various Artists'

  return {
    artist: artist,
    album: album,
    meta: meta,
    year: year
  }

}
