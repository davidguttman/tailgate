leveljs = require 'level-js'
levelup = require 'levelup'

module.exports = levelup 'tailgate',
  db: leveljs
  valueEncoding: 'json'
