process.env.NODE_ENV ?= 'development'

createServer = require './server'
server = createServer()

port = process.env.PORT or 3000

server.listen port, ->
  console.log "[TAILGATE] Running on port #{port}".green
