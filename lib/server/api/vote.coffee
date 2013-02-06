normalize = require '../normalize_path'
{Votes} = require '../db'

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

module.exports =
  up: up
  down: down
  clear: clear



