leveljs = require 'level-js'
levelup = require 'levelup'

dbName = 'tailgate'

module.exports = levelup dbName,
  db: leveljs
  valueEncoding: 'json'

module.exports.reset = ->
  indexedDB.deleteDatabase dbName
