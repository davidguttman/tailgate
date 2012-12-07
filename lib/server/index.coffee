fs              = require 'fs'
request         = require 'request'
express         = require 'express'
RedisStore      = (require 'connect-redis') express

bundle = require './bundle'

app = express()

setUser = (req, res, next) ->
  app.locals.currentUser = req.session.currentUser
  next()

app.configure ->
  app.use express.cookieParser()
  app.use express.session
    secret: "the linguistic cyclist fusses beneath an overloaded assistant"
    # store: new RedisStore
  app.use setUser
  app.use express.bodyParser()
  app.use express.static './public'
  app.use bundle
  app.use express.logger 'dev'

app.set 'views', './views'

app.get '/', (req, res) ->
  if req.session.currentUser
    res.render 'index.jade'
  else
    res.render 'login.jade'

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
    if body.email
      req.session.currentUser = body.email
      res.send req.session.desiredUrl or "/"
    else
      res.send '/'

  request reqOpts, onResponse


port = process.env.PORT or 3000

app.listen port, ->
  console.log "Express running on port #{port}"