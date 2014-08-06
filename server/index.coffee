fs              = require 'fs'
colors          = require 'colors'
request         = require 'request'
express         = require 'express'
RedisStore      = (require 'connect-redis') express

auth = require './auth'
config = require './config'

art = require './api/art'
get = require './api/get'
vote = require './api/vote'

app = express()

setUser = (req, res, next) ->
  app.locals.currentUser = req.session.currentUser
  next()

module.exports = (opts) ->
  app.configure ->
    app.use express.cookieParser()
    app.use express.session
      secret: config.data.secret
      store: new RedisStore if opts.redisEnabled
      maxAge: 365 * 24 * 3600 * 1000
    app.use setUser
    app.use express.bodyParser()
    app.use express.static __dirname + '/../public'
    app.use express.logger 'dev'

  app.set 'views', __dirname + '/views'

  app.get  '/', (req, res) -> res.render 'index.ejs'

  app.post '/get-code', auth.getCode
  app.post '/login', auth.login
  app.get  '/logout', (req, res) ->
    req.session.currentUser = null
    res.redirect '/'

  app.get '/api/art', auth.check, art
  app.get '/api/get', auth.check, get
  app.get '/api/upvote', auth.check, vote.up
  app.get '/api/downvote', auth.check, vote.down
  app.get '/api/clearvote', auth.check, vote.clear
  app.get '/api/upvotes', auth.check, vote.upvotes
  app.get '/api/downvotes', auth.check, vote.downvotes

  port = process.env.PORT or 3000
  console.log 'port', port

  app.listen port, ->
    console.log "[TAILGATE] Running on port #{port}".green

  return app
