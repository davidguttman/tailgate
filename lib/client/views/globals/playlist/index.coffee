windowState = require '../../../models/window_state'
player = require '../../../models/player'
playlist = require '../../../collections/playlist'
template = require './playlist.jade'

Playlist = Backbone.View.extend
  className: 'playlist'

  events:
    'click .list tr': 'select'
    
    'click .actions .remove': 'removeItem'
    'click .actions .vote-up': 'voteUp'
    'click .actions .vote-down': 'voteDown'

    'click .window-collapse': 'collapse'
    'click .window-expand': 'expand'
  
  initialize: ->
    _.bindAll this

    @windowState = windowState()
    @windowState.on 'change:playlist', @render

    @collection = playlist()
    @collection.on 'add', @render
    @collection.on 'remove', @render
    @collection.on 'reset', @render
    @collection.on 'change', @render

    @player = player()

    @player.on 'change:selected', @render

    @render()

  render: ->
    active = @windowState.get 'playlist'

    @$el.html template
      items: @collection.models
      selected: @player.selected()
      active: active

  voteUp: (e) ->
    cid = $(e.currentTarget).data 'cid'
    item = @collection.byCid cid
    if item?
      curVote = item.get 'vote'
      if curVote is 1
        item.clearvote()
      else
        item.upvote()

    e.stopPropagation()

  voteDown: (e) ->
    cid = $(e.currentTarget).data 'cid'
    item = @collection.byCid cid
    if item?
      curVote = item.get 'vote'
      if curVote is -1
        item.clearvote()
      else
        item.downvote()

    e.stopPropagation()

  removeItem: (e) ->
    cid = $(e.currentTarget).data 'cid'
    @player.remove cid
    e.stopPropagation()

  select: (e) ->
    console.log 'select...'
    cid = $(e.currentTarget).data 'cid'
    console.log 'cid', cid
    @player.select cid
    e.preventDefault()

  collapse: ->
    @windowState.set 'playlist': false

  expand: ->
    @windowState.set 'playlist': true

cache = null

module.exports = ->
  cache = cache or new Playlist