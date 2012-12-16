controls       = require './controls'
main      = require './main'
playlist  = require './playlist'

globalViews = null

module.exports = ->
  return globalViews if globalViews

  globalViews = 
    main: main()
    controls: controls()
    playlist: playlist()

  globalViews.elements = [
    globalViews.controls.el
    globalViews.playlist.el
    globalViews.main.el
  ]

  return globalViews