directoryView = require '../views/directory'

path = ->
  @ensureParams {path: '/'}

  view = directoryView @params

  @target.html view.el

module.exports = 
  '/': ->
    location.hash = '/directory'

  '/directory': path
  '/directory/:json': path