config = require '../../../config/tailgate.json'
root = config.directory

fs = require 'fs'
parse = require('url').parse
path = require 'path'
normalize = path.normalize
extname = path.extname
join = path.join

directory = require './directory'
file = require './file'

module.exports = (req, res) ->
  url = parse(req.url)
  dir = decodeURIComponent(req.query.path)
  path = normalize(join(root, dir))
  originalUrl = parse(req.originalUrl)
  originalDir = decodeURIComponent(originalUrl.pathname)
  showUp = path isnt root and path isnt root + "/"
  
  # null byte(s), bad request
  return res.send 400 if ~path.indexOf("\u0000")
  
  # malicious path, forbidden
  return res.send 403 unless 0 is path.indexOf(root)
  
  # check if we have a directory
  fs.stat path, (err, stat) ->
    return (if "ENOENT" is err.code then next() else next(err))  if err
    if stat.isDirectory()
      directory req, res, path
    else
      file req, res, path