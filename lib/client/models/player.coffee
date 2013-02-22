playlist = require '../collections/playlist'
sounds = {}

Player = Backbone.Model.extend
  defaults:
    status: 'stopped'
    selected: null
    progress: 0

  initialize: ->
    _.bindAll this, 'next', 'onUpdate'

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
      self = this

      @set status: 'playing'
      item = @playlist().getByCid @selected()
      
      soundManager.stopAll()

      soundId = item.cid + item.get 'name'

      sounds[soundId] ?= soundManager.createSound
        id: soundId
        url: decodeURI(item.get 'url')
        stream: true
        onfinish: @next
        whileplaying: ->
          self.onUpdate this
        
      sounds[soundId].play()

  stop: ->
    soundManager.stopAll()
    @set
      status: 'stopped'


  remove: (cid) ->
    @stop() if cid is @selected()
      
    item = @playlist().getByCid cid
    @playlist().remove item


  onUpdate: (sound) ->
    @set 
      progress: sound.position/sound.duration
  

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
    if cid? and cid isnt @get 'selected'
      @set selected: cid 
      @playSelected()

  clear: ->
    soundManager.stopAll()
    @playlist().reset()
    @set @defaults

  playlist: ->
    @get 'playlist'

  selected: ->
    @get 'selected'

  status: ->
    @get 'status'

cache = null

module.exports = () ->
  cache = cache or new Player 
    playlist: playlist()