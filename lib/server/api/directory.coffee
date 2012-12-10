async = require 'async'
fs = require 'fs'

path = require 'path'
normalize = path.normalize
extname = path.extname
join = path.join

fileStat = (dirPath, file, cb) ->
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
      ext: extname(file).replace '.', ''

sendStats = (req, res, path, files) ->
  fn = async.apply fileStat, path
  async.map files, fn, (err, stats) ->
    return res.send 500, err.message if err

    res.json stats

removeHidden = (files) ->
  files.filter (file) ->
    "." isnt file[0]

module.exports = directory = (req, res, path) ->
  fs.readdir path, (err, files) ->
    return next(err)  if err
    files = removeHidden(files)
    files.sort()
    sendStats req, res, path, files

