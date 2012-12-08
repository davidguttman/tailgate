sounds = {}

Player = Backbone.Model.extend
  defaults:
    status: 'stopped'
    selected: null

  initialize: ->
    console.log 'player!'

  play: ->
    if @status() is 'playing'
      return

    if @status() is 'paused'
      soundManager.resumeAll()
      @set status: 'playing'
    
    if @status() is 'stopped'
      unless @selected()
        cid = @playlist().at(0)?.cid

        @set selected: cid if cid?

      @playSelected()

  playSelected: ->
    if @selected()
      @set status: 'playing'
      item = @playlist().getByCid @selected()
      
      soundManager.stopAll()

      soundId = item.cid + item.get 'name'

      sounds[soundId] ?= soundManager.createSound
        id: soundId
        url: item.get 'url'
        whileplaying: @onUpdate
        stream: true
        
      sounds[soundId].play()


  onUpdate: ->

    # console.log 'this.position/this.duration', this.position/this.duration

  indexForCid: (cid) ->
    index = null
    for item, i in @playlist().models
      index = i if item.cid is cid

    return index

  select: (cid) ->
    @set selected: cid
    @playSelected()

  pause: ->
    if @status() is 'playing'
      soundManager.pauseAll()
      @set status: 'paused'

  prev: ->
    index = @indexForCid @selected() 
    return unless index?
  
    nextItem = @playlist().at (index-1)
    cid = nextItem?.cid
    @set selected: cid if cid?
    @playSelected()

  next: ->
    index = @indexForCid @selected()
    return unless index?
  
    nextItem = @playlist().at (index+1)
    cid = nextItem?.cid
    @set selected: cid if cid?
    @playSelected()

  clear: ->
    @playlist().reset()
    @set @defaults
    # @trigger 'change'

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