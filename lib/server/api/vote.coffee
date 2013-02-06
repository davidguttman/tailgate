normalize = require '../normalize_path'
{Votes} = require '../db'

up = (req, res, next) ->
  filepath = normalize req.query.path
  Votes.upvote filepath
  res.send 200

down = (req, res, next) ->

module.exports =
  up: up
  down: down




