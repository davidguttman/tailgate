fs              = require 'fs'
Level           = require 'level'
colors          = require 'colors'
request         = require 'request'
express         = require 'express'
RedisStore      = (require 'connect-redis') express

db = Level __dirname + '/../db', valueEncoding: 'json'

config = require './config'
emailer = require './emailer'

codeExpirationTime = 15 * 60 * 1000 # 15 minutes
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
  authorizedUsers = config.data.users.map (email) -> email.toLowerCase()
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

  app.set 'views', __dirname + '/views'

  app.get '/', (req, res) -> res.render 'index.ejs'

  app.get '/api/get', auth, get
  app.get '/api/upvote', auth, vote.up
  app.get '/api/downvote', auth, vote.down
  app.get '/api/clearvote', auth, vote.clear
  app.get '/api/upvotes', auth, vote.upvotes
  app.get '/api/downvotes', auth, vote.downvotes

  app.post '/get-code', (req, res) ->
    email = req.body.email
    return res.send 400 unless email

    audience = 'http://' + req.headers.host

    generateCode email, (err, code) ->
      return console.error err if err
      email =
        to: email
        from: 'auth@tailgate.io'
        subject: "Your access code is: #{code}"
        text: "Your access code is: #{code}"
      emailer email, (err) ->
        return res.json 500, {success: false} if err
        res.json 200, {success: true}

  app.post '/login', (req, res) ->
    email = req.body.email
    code = req.body.code

    if email and code
      validateCode email, code, (err, success) ->
        if success
          if isOpenMode
            createUser email

          if email in authorizedUsers
            req.session.currentUser = email
            return res.json 200, {success: true}

        console.log "[TAILGATE] Not Authorized: #{email} ".red
        return res.json 403, {success: false}
    else
      return res.json 400, {success: false}

  app.get '/logout', (req, res) ->
    req.session.currentUser = null
    res.redirect '/'

  generateCode = (email, cb) ->
    code = Math.floor Math.random() * 9999
    key = ['auth', email].join '\xff'
    auth =
      email: email
      code: code.toString()
      expires: Date.now() + codeExpirationTime

    console.log "[TAILGATE] Auth Code for #{email}: #{code} ".yellow

    db.put key, auth, cb

  validateCode = (email, codeAssert, cb) ->
    key = ['auth', email].join '\xff'
    db.get key, (err, auth) ->
      return cb err if err
      return cb null, false unless auth
      return cb null, false if Date.now() > auth.expires
      return cb null, false unless codeAssert is auth.code

      return cb null, true

  port = process.env.PORT or 3000
  console.log 'port', port

  app.listen port, ->
    console.log "[TAILGATE] Running on port #{port}".green

  return app
