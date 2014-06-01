send = require 'send'
{root} = require '../normalize_path'

module.exports = (req, res, path) ->
  send(req, path).root('/').pipe res
