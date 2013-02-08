redis = require('redis').createClient()

Votes = 
  ns: 'tailgate:votes'

  upkey: 'tailgate:upvotes'
  downkey: 'tailgate:downvotes'

  get: (filename, callback) ->
    upkey = @upkey
    downkey = @downkey

    redis.sismember upkey, filename, (err, hasUp) ->
      return callback err if err

      redis.sismember downkey, filename, (err, hasDown) ->
        return callback err if err

        vote = hasUp + (-1 * hasDown)
        
        callback null, vote

  upvote: (filename) ->
    redis.sadd @upkey, filename
    redis.srem @downkey, filename

  downvote: (filename) ->
    redis.sadd @downkey, filename
    redis.srem @upkey, filename

  clearvote: (filename) ->
    redis.srem @upkey, filename
    redis.srem @downkey, filename

  upvotes: (callback) ->
    redis.smembers @upkey, callback

  downvotes: (callback) ->
    redis.smembers @downkey, callback
    
module.exports = 
  Votes: Votes