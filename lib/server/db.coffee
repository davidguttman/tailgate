redis = require('redis').createClient()

Votes = 
  ns: 'tailgate:votes'

  fnkey: (filename) -> "#{@ns}:#{filename}"

  get: (filename, callback) ->
    key = @fnkey filename
    redis.get key, (err, value) ->
      return callback err if err
      vote = (parseInt value, 10) or 0
      callback null, vote

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