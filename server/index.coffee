fs = require 'fs'
st = require 'st'
URL = require 'url'
http = require 'http'
colors = require 'colors'
request = require 'request'
ReqLogger = require 'req-logger'
Authentic = require 'authentic-service'
healthRoute = require 'health-route'
HttpHashRouter = require 'http-hash-router'

config = require './config'
art = require './api/art'
get = require './api/get'
{version} = require '../package.json'

logger = ReqLogger version: version

mount = st
  url: '/'
  passthrough: true
  index: 'index.html'
  path: __dirname + '/../public'
  cache: false if process.env.NODE_ENV isnt 'production'

auth = Authentic
  server: 'https://authentic.thhis.com'

router = HttpHashRouter()
router.set('/health', healthRoute)
router.set('/api/art', art)
router.set('/api/get', get)

module.exports = (opts={}) ->
  authFn = checkAuth
  if opts.authData
    authFn = (req, res, next) ->
      req.authData = opts.authData
      setImmediate next

  handler = (req, res) ->
    mount req, res, ->
      logger req, res if process.env.NODE_ENV isnt 'test'

      onError = (err) ->
        err.statusCode ?= 500
        console.error err
        res.end err.message

      authFn req, res, (err) ->
        return onError err if err
        router req, res, {}, onError

  http.createServer handler

checkAuth = (req, res, cb) ->
  parsed = URL.parse req.url, true
  req.query = parsed.query

  if req.query._authToken
    req.headers.authorization = 'Bearer ' + req.query._authToken

  auth req, res, (err, authData) ->
    return console.error err if err

    req.authData = authData or {}
    email = req.authData.email

    unless email and email in config.data.users
      err = new Error 'Unauthorized'
      err.statusCode = 403

    cb err
