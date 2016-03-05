fs              = require 'fs'
colors          = require 'colors'
request = require 'request'
express = require 'express'
Authentic = require 'authentic-service'
healthRoute = require 'health-route'

auth = Authentic
  server: 'https://authentic.thhis.com'

config = require './config'

art = require './api/art'
get = require './api/get'

checkAuth = (req, res, next) ->
  if req.query._authToken
    req.headers.authorization = 'Bearer ' + req.query._authToken

  auth req, res, (err, authData) ->
    return console.error err if err

    req.authData = authData or {}

    return res.send 403 unless req.authData.email
    return res.send 403 unless req.authData.email in config.data.users

    next()

module.exports = (opts={}) ->
  app = express()

  if opts.skipAuth
    authFn = (req, res, next) -> next()
  else
    authFn = checkAuth

  app.configure ->
    app.use express.static __dirname + '/../public'
    app.use express.logger 'dev'

  app.set 'views', __dirname + '/views'

  app.get '/health', healthRoute
  app.get '/', (req, res) -> res.render 'index.ejs'

  app.get '/api/art', authFn, art
  app.get '/api/get', authFn, get

  return app
