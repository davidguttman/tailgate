top       = require './top'
main      = require './main'

globalViews = null

module.exports = ->
  return globalViews if globalViews

  globalViews = 
    main: main()
    top: top()

  globalViews.elements = [
    globalViews.top.el
    globalViews.main.el
  ]

  return globalViews