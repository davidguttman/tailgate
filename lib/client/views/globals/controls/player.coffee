player = require '../../../models/player'
playlist = require '../../../collections/playlist'
template = require '../../../templates/controls/player'

Player = Backbone.View.extend
  className: 'player'

  events:
    'click button.prev': 'prev'
    'click button.play': 'play'
    'click button.pause': 'pause'
    'click button.clear': 'clear'
    'click button.next': 'next'
  
  initialize: ->
    _.bindAll this

    @player = player()

    @player.on 'change:selected', @render
    @player.on 'change:status', @render
    @player.on 'change:progress', @renderProgress


    @render()

  render: ->
    console.log '@player.selected()', @player.selected()
    @$el.html template
      selected: @player.selected()
      playing: @player.status() is 'playing'
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
    console.log 'PREV!'
    @player.prev()

  playPause: ->
    if @player.status() is 'playing'
      @player.pause()
    else
      @player.play()

  play: ->
    @player.play()

  pause: ->
    @player.pause()

  clear: ->
    # if confirm 'Clear playlist?'
    @player.clear()

  next: ->
    @player.next()


cache = null

module.exports = ->
  cache = cache or new Player