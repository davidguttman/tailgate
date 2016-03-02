fs = require 'fs'
parse = require('url').parse
extname = (require 'path').extname
sendJson = require('send-data/json')

normalize = require '../normalize_path'
root = normalize.root

directory = require './directory'
file = require './file'

module.exports = (req, res, opts, next) ->
  url = parse(req.url, true)
  dir = url.query.path
  filepath = normalize dir

  # null byte(s), bad request
  if ~filepath.indexOf("\u0000")
    err = new Error 'Bad Request'
    err.statusCode = 400
    return cb err

  # malicious path, forbidden
  unless 0 is filepath.indexOf(root)
    err = new Error 'Forbidden'
    err.statusCode = 403
    return cb err

  # check if we have a directory
  fs.stat filepath, (err, stat) ->
    if err
      err.statusCode = 404 if "ENOENT" is err.code
      return next err

    return file req, res, filepath unless stat.isDirectory()

    directory filepath, (err, dir) ->
      return cb err if err
      sendJson req, res, dir
