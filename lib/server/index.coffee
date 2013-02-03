fs              = require 'fs'
colors          = require 'colors'
request         = require 'request'
express         = require 'express'
RedisStore      = (require 'connect-redis') express

config = require './config'

authorizedUsers = config.data.users
isOpenMode = authorizedUsers.length is 0
if isOpenMode
  console.log "[TAILGATE] Running in 'open mode'".yellow


bundle = require './bundle'
get = require './api/get'

app = express()

createUser = (email) ->
  console.log "[TAILGATE] #{email} added to users".green
  console.log "[TAILGATE] Running in 'closed mode'".green
  config.data.users.push email
  config.save()
  

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
    secret: config.data.secret
    # store: new RedisStore
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
    if isOpenMode and body.email
      createUser body.email
      req.session.currentUser = body.email
      res.send "/"
    else if body.email in authorizedUsers
      req.session.currentUser = body.email
      res.send req.session.desiredUrl or "/"
    else
      console.log "[TAILGATE] Not Authorized: #{body.email} ".red
      res.send '/'

  request reqOpts, onResponse


port = process.env.PORT or 3000

app.listen port, ->
  console.log "[TAILGATE] Running on port #{port}".green