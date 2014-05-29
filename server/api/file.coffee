send = require 'send'

module.exports = (req, res, path) ->
  send(req, path).pipe res