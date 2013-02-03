fs              = require 'fs'
request         = require 'request'
express         = require 'express'
RedisStore      = (require 'connect-redis') express

config = require './config'

authorizedUsers = config.users.map (user) -> user.email

bundle = require './bundle'
get = require './api/get'

app = express()

setUser = (req, res, next) ->
  app.locals.currentUser = req.session.currentUser
  next()

auth = (req, res, next) ->
  if req.session.currentUser
    next()
  else
    res.send 404

app.configure ->
  app.use express.cookieParser()
  app.use express.session
    secret: "the linguistic cyclist fusses beneath an overloaded assistant"
    store: new RedisStore
  app.use setUser
  app.use express.bodyParser()
  app.use express.static __dirname + '/../../public'
  app.use bundle
  app.use express.logger 'dev'

app.set 'views', __dirname + '/../../views'

app.get '/', (req, res) ->
  if req.session.currentUser
    res.render 'index.jade'
  else
    res.render 'login.jade'

app.get '/api/get', auth, get

app.post "/login", (req, res) ->
  token = req.body.token
  audience = "http://" + req.headers.host
  reqOpts =
    url: "https://browserid.org/verify"
    method: "POST"
    json:
      assertion: token
      audience: audience

  onResponse = (err, resp, body) ->
    if body.email in authorizedUsers
      req.session.currentUser = body.email
      res.send req.session.desiredUrl or "/"
    else
      res.send '/'

  request reqOpts, onResponse


port = process.env.PORT or 3000

app.listen port, ->
  console.log "Express running on port #{port}"