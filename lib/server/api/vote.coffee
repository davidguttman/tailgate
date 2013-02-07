normalize = require '../normalize_path'
{Votes} = require '../db'

unNormalizePaths = (paths) ->
  unNormalized = []
  for item in paths
    re = new RegExp "^#{normalize.root}"
    if item.match re
      unNormalized.push (item.replace re, '')
  return unNormalized

up = (req, res, next) ->
  filepath = normalize req.query.path
  Votes.upvote filepath
  res.send 200

down = (req, res, next) ->
  filepath = normalize req.query.path
  Votes.downvote filepath
  res.send 200

clear = (req, res, next) ->
  filepath = normalize req.query.path
  Votes.clearvote filepath
  res.send 200

upvotes = (req, res, next) ->
  Votes.upvotes (err, upvotes) ->
    paths = unNormalizePaths upvotes
    res.send paths

downvotes = (req, res, next) ->
  Votes.downvotes (err, downvotes) ->
    paths = unNormalizePaths downvotes
    res.send paths

module.exports =
  up: up
  down: down
  clear: clear
  upvotes: upvotes
  downvotes: downvotes



