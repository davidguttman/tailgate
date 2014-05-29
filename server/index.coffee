fs              = require 'fs'
colors          = require 'colors'
request         = require 'request'
express         = require 'express'
RedisStore      = (require 'connect-redis') express

config = require './config'

authorizedUsers = config.data.users.map (email) -> email.toLowerCase()
isOpenMode = authorizedUsers.length is 0
if isOpenMode
  console.log "[TAILGATE] Running in 'open mode'".yellow

get = require './api/get'
vote = require './api/vote'

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

module.exports = (opts) ->
  app.configure ->
    app.use express.cookieParser()
    app.use express.session
      secret: config.data.secret
      store: new RedisStore if opts.redisEnabled
    app.use setUser
    app.use express.bodyParser()
    app.use express.static __dirname + '/../public'
    app.use express.logger 'dev'

  console.log 'configure done'

  app.set 'views', __dirname + '/views'

  app.get '/', (req, res) ->
    if req.session.currentUser
      res.render 'index.ejs'
    else
      res.render 'login.jade'

  app.get '/api/get', auth, get
  app.get '/api/upvote', auth, vote.up
  app.get '/api/downvote', auth, vote.down
  app.get '/api/clearvote', auth, vote.clear
  app.get '/api/upvotes', auth, vote.upvotes
  app.get '/api/downvotes', auth, vote.downvotes

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
      email = body.email?.toLowerCase()

      if isOpenMode and email
        createUser email
        req.session.currentUser = email
        res.send "/"
      else if email in authorizedUsers
        req.session.currentUser = email
        res.send req.session.desiredUrl or "/"
      else
        console.log "[TAILGATE] Not Authorized: #{email} ".red
        res.send '/'

    request reqOpts, onResponse


  port = process.env.PORT or 3000
  console.log 'port', port

  app.listen port, ->
    console.log "[TAILGATE] Running on port #{port}".green

  return app
