fs = require("fs")
parse = require("url").parse
path = require("path")
normalize = path.normalize
extname = path.extname
join = path.join

config = require '../../../config/tailgate.json'
root = config.directory

directory = (req, res, next) ->
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
    return next()  unless stat.isDirectory()
    
    # fetch files
    fs.readdir path, (err, files) ->
      return next(err)  if err
      files = removeHidden(files)
      files.sort()
      
      json req, res, files, next, originalDir, showUp

json = (req, res, files) ->
  console.log 'arguments', arguments
  files = JSON.stringify(files)
  res.setHeader "Content-Type", "application/json"
  res.setHeader "Content-Length", files.length
  res.end files

removeHidden = (files) ->
  files.filter (file) ->
    "." isnt file[0]

module.exports =
  directory: directory