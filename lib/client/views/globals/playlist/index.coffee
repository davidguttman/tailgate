player = require '../../../models/player'
playlist = require '../../../collections/playlist'
template = require '../../../templates/playlist'

Playlist = Backbone.View.extend
  className: 'playlist span4'

  events:
    'click i.icon-step-backward': 'prev'
    'click i.icon-play': 'play'
    'click i.icon-pause': 'pause'
    'click i.icon-remove-sign': 'clear'
    'click i.icon-step-forward': 'next'

    'click .list a': 'select'
    'click .list a i.icon-remove-circle': 'removeItem'
  
  initialize: ->
    _.bindAll this

    @collection = playlist()
    @collection.on 'add', @render
    @collection.on 'remove', @render
    @collection.on 'reset', @render

    @player = player @collection

    @player.on 'change:selected', @render
    @player.on 'change:status', @render
    @player.on 'change:progress', @renderProgress


    @render()

  render: ->
    console.log '@player.selected()', @player.selected()
    @$el.html template
      items: @collection.models
      selected: @player.selected()
    @renderProgress()

  renderProgress: ->
    progress = @player.get 'progress'
    @$('.progress .bar').css 'width', "#{progress * 100}%"

  removeItem: (e) ->
    cid = $(e.target).data 'cid'
    @player.remove cid
    e.stopPropagation()

  select: (e) ->
    console.log 'select...'
    cid = $(e.target).data 'cid'
    @player.select cid
    e.preventDefault()

  prev: ->
    @player.prev()

  play: ->
    @player.play()

  pause: ->
    @player.pause()

  clear: ->
    if confirm 'Clear playlist?'
      @player.clear()

  next: ->
    @player.next()




cache = null

module.exports = ->
  cache = cache or new Playlist