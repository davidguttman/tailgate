redis = require('redis').createClient()

Votes = 
  ns: 'tailgate:votes'

  fnkey: (filename) -> "#{@ns}:#{filename}"

  get: (filename, callback) ->
    key = @fnkey filename
    redis.get key, (err, value) ->
      return callback err if err

      callback null, (value or "0")

  upvote: (filename) ->
    key = @fnkey filename
    redis.set key, "1"

  downvote: (filename) ->
    key = @fnkey filename
    redis.set key, "-1"

  clearvote: (filename) ->
    key = @fnkey filename
    redis.del key

module.exports = 
  Votes: Votes