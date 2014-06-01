leveljs = require 'level-js'
levelup = require 'levelup'

dbName = 'tailgate'

module.exports = db = levelup dbName,
  db: leveljs
  valueEncoding: 'json'

module.exports.reset = ->
  setTimeout ->
    db.createKeyStream().on 'data', db.del.bind(db)
  , 1000
