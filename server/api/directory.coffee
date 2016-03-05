fs = require 'fs'
path = require 'path'
map = require 'map-async'

normalize = path.normalize
extname = path.extname
join = path.join

fileStat = (dirPath, file, cb) ->
  filepath = normalize(join(dirPath, file))

  fs.stat filepath, (err, results) ->
    return cb err if err

    info =
      name: file
      isDirectory: results.isDirectory()
      size: results.size
      atime: results.atime
      mtime: results.mtime
      ctime: results.ctime
      ext: extname(file).replace '.', ''

    cb null, info

removeHidden = (files) ->
  files.filter (file) ->
    "." isnt file[0]

module.exports = directory = (filepath, cb) ->
  fs.readdir filepath, (err, files) ->
    return cb(err) if err
    files = removeHidden(files)
    files.sort()

    map files, fileStat.bind(null, filepath), cb


