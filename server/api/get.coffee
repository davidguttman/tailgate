fs = require 'fs'
parse = require('url').parse
extname = (require 'path').extname
normalize = require '../normalize_path'
root = normalize.root

directory = require './directory'
file = require './file'

module.exports = (req, res, next) ->
  url = parse(req.url, true)
  dir = url.query.path
  filepath = normalize dir

  originalUrl = parse(req.originalUrl)
  originalDir = decodeURIComponent(originalUrl.pathname)
  showUp = filepath isnt root and filepath isnt root + "/"

  # null byte(s), bad request
  return res.send 400 if ~filepath.indexOf("\u0000")

  # malicious path, forbidden
  return res.send 403 unless 0 is filepath.indexOf(root)

  # check if we have a directory
  fs.stat filepath, (err, stat) ->
    return (if "ENOENT" is err.code then next() else next(err))  if err
    if stat.isDirectory()
      directory req, res, filepath
    else
      file req, res, filepath
