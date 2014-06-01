async = require 'async'
fs = require 'fs'
path = require 'path'
normalize = path.normalize
extname = path.extname
join = path.join
zip = require 'express-zip'

{Votes} = require '../db'

fileStat = (dirPath, file, cb) ->
  filepath = normalize(join(dirPath, file))

  Votes.get filepath, (err, vote) ->

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

      info.vote = vote unless info.isDirectory

      cb null, info


sendStats = (req, res, filepath, files) ->
  fn = async.apply fileStat, filepath
  async.map files, fn, (err, stats) ->
    return res.send 500, err.message if err

    res.json stats

removeHidden = (files) ->
  files.filter (file) ->
    "." isnt file[0]

sendZip = (files, dirPath, res) ->
  files = files.map (file) ->
    name: file
    path: normalize(join(dirPath, file))

  res.zip files, (path.basename dirPath) + '.zip'

module.exports = directory = (req, res, filepath) ->
  fs.readdir filepath, (err, files) ->
    return next(err)  if err
    files = removeHidden(files)
    files.sort()

    if req.query.zip is 'true'
      sendZip files, filepath, res
    else
      sendStats req, res, filepath, files


