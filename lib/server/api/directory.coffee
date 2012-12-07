async = require 'async'
fs = require 'fs'

path = require 'path'
normalize = path.normalize
extname = path.extname
join = path.join

fileStat = (dirPath, file, cb) ->
  console.log 'arguments', arguments
  path = normalize(join(dirPath, file))
  fs.stat path, (err, results) ->
    return cb err if err

    cb null,
      name: file
      isDirectory: results.isDirectory()
      size: results.size
      atime: results.atime
      mtime: results.mtime
      ctime: results.ctime

sendStats = (req, res, path, files) ->
  fn = async.apply fileStat, path
  async.map files, fn, (err, stats) ->
    return res.send 500, err.message if err

    files = JSON.stringify(stats)
    res.setHeader "Content-Type", "application/json"
    res.setHeader "Content-Length", files.length
    res.end files

removeHidden = (files) ->
  files.filter (file) ->
    "." isnt file[0]

module.exports = directory = (req, res, path) ->
  fs.readdir path, (err, files) ->
    return next(err)  if err
    files = removeHidden(files)
    files.sort()
    sendStats req, res, path, files

