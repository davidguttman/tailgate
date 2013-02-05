{Votes} = require '../db'

up = (req, res, next) ->
  path = req.query.path
  Votes.upvote path
  res.send 200

down = (req, res, next) ->

module.exports =
  up: up
  down: down