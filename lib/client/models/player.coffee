Player = Backbone.Model.extend
  defaults:
    status: 'stopped'
    selected: null

  initialize: ->
    console.log 'player!'

  play: ->
    return if @status() is 'playing'
    
    unless @selected()
      cid = @playlist().at(0)?.cid

      @set selected: cid if cid?

    if @selected()
      @set status: 'playing'

  indexForCid: (cid) ->
    index = null
    for item, i in @playlist().models
      index = i if item.cid is cid

    return index

  select: (cid) ->
    @set selected: cid

  prev: ->
    index = @indexForCid @selected() 
    return unless index?
  
    nextItem = @playlist().at (index-1)
    cid = nextItem?.cid
    @set selected: cid if cid?

  next: ->
    index = @indexForCid @selected()
    return unless index?
  
    nextItem = @playlist().at (index+1)
    cid = nextItem?.cid
    @set selected: cid if cid?

  clear: ->
    @playlist().reset()
    @set @defaults
    @trigger 'change'

  playlist: ->
    @get 'playlist'

  selected: ->
    @get 'selected'

  status: ->
    @get 'status'

cache = null

module.exports = (playlist) ->
  cache = cache or new Player 
    playlist: playlist