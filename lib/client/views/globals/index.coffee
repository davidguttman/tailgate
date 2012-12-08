top       = require './top'
main      = require './main'
playlist  = require './playlist'

globalViews = null

module.exports = ->
  return globalViews if globalViews

  globalViews = 
    main: main()
    top: top()
    playlist: playlist()

  globalViews.elements = [
    globalViews.top.el
    globalViews.playlist.el
    globalViews.main.el
  ]

  return globalViews