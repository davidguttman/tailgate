template = require '../../../templates/controls/window_manager'
windowState = require '../../../models/window_state'

WindowManager = Backbone.View.extend
  
  events:
    'click button.playlist': 'togglePlaylist'
    'click button.directories': 'toggleDirectories'
    'click button.files': 'toggleFiles'

  initialize: ->
    _.bindAll this

    @state = windowState()
    @state.on 'change', @render

    @render()

  render: ->
    @$el.html template()
    for name, active of @state.toJSON()
      query = "button.#{name}"
      @$(query).addClass 'active' if active

  togglePlaylist: -> @toggle 'playlist'
  toggleDirectories: -> @toggle 'directories'
  toggleFiles: -> @toggle 'files'

  toggle: (windowName) ->
    opts = {}
    opts[windowName] = not (@state.get windowName)

    @state.set opts


cache = null

module.exports = ->
  cache = cache or new WindowManager