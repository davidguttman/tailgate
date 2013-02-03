process.env.NODE_ENV ?= 'development'

_ = require 'underscore'
colors = require 'colors'
redis = require 'redis'
client = redis.createClient()

start = _.once (redisEnabled) ->
  client.quit()
  if redisEnabled
    console.log "[TAILGATE] Redis found, persistence enabled".green
  else
    console.log "[TAILGATE] Redis not found, persistence disabled".yellow

  (require './server') redisEnabled: redisEnabled

client.on 'ready', -> start true
client.on 'error', -> start false