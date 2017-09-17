var React = require('react')
var rebass = require('rebass')
var moment = require('moment')
var Icon = require('react-geomicons').default
var playAudio = require('dg-play-audio')

var api = require('./api')
var Loading = require('./loading.jsx')

var Text = rebass.Text
var Card = rebass.Card
var Heading = rebass.Heading
var Progress = rebass.Progress
var CardImage = rebass.CardImage
var Container = rebass.Container
var ButtonCircle = rebass.ButtonCircle
var DotIndicator = rebass.DotIndicator

var Player = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      albumPath: null,
      shareCode: null,
      onFinish: function () {}
    }
  },

  getInitialState: function() {
    return {
      albumName: null,
      isPlaying: false,
      tracks: [],
      coverArt: null,
      idxTrack: 0,
      idxLoaded: null,
      audioPlayer: null,
      currentTime: null,
      duration: null
    }
  },

  componentWillReceiveProps: function (nextProps) {
    if (!nextProps.albumPath) return
    if (nextProps.albumPath === this.props.albumPath) return
    this.loadAlbum(nextProps.albumPath)
  },

  componentWillMount: function() {
    if (!this.props.albumPath) return
    this.loadAlbum(this.props.albumPath)
  },

  loadAlbum: function (albumPath) {
    var self = this

    this.setState({_isLoading: true})

    api.getAlbum(albumPath, this.props.shareCode, function (err, album) {
      if (err) return console.error(err)

      self.setState({
        tracks: album.tracks,
        coverArt: album.coverArt,
        albumName: album.name,
        artist: album.artist,
        idxTrack: 0,
        idxLoaded: null,
        currentTime: null,
        duration: null,
        _isLoading: false
      })

      self._loadIdx(0)
      if (self.state.isPlaying) self._play()
    })
  },

  render: function () {
    if (!this.state.tracks.length) {
      return <div style={{height: 256}}><Loading /></div>
    }

    return (
      <div style={{paddingTop: 0}}>
        { this.state._isLoading ? <Loading /> : this.renderPlayer() }
      </div>
    )
  },

  renderPlayer: function () {
    var track = this.state.tracks[this.state.idxTrack] || {name: '', ext: 'mp3'}
    var trackName = track.name.replace('.' + track.ext, '')

    return (
      <Card style={{marginBottom: 10}}>

        {!this.state.coverArt ? '' : <CardImage src={this.state.coverArt} />}

        <div style={{textAlign: 'center'}}>
          <Text style={{fontWeight: 'bold', marginBottom: 10}}>
            {trackName}
          </Text>

          <Text style={{marginBottom: 10}}>
            {this.state.artist}
          </Text>

          <Text style={{
            fontStyle: 'italic',
            fontSize: '80%',
            marginBottom: 20 }} >
            {this.state.albumName}
          </Text>
        </div>

        { this.renderProgress() }
        { this.renderActions() }

      </Card>
    )
  },

  renderProgress: function () {
    var duration = this.state.duration
    var currentTime = this.state.currentTime

    if (!duration || !currentTime) {
      var progress = 0
      var duration = '00:00'
      var time = '00:00'
    } else {
      var fmtString = duration > 3600 ? 'H:mm:ss' : 'mm:ss'
      var progress = currentTime / duration
      var duration = moment(duration * 1000).utc().format(fmtString)
      var time = moment(currentTime * 1000).utc().format(fmtString)
    }

    var styleTime = {
      display: 'flex',
      justifyContent: 'space-between',
      fontSize: '70%',
      marginTop: -15
    }

    return (
      <div>
        <Progress
          color={'primary'}
          style={{cursor: 'pointer'}}
          onClick={this._setProgress}
          value={progress} >
        </Progress>

        <div style={styleTime}>
          <span> {time} </span>
          <span> {duration} </span>
        </div>
      </div>
    )
  },

  renderActions: function () {
    var styleActions = {
      display: 'flex',
      justifyContent: 'space-between',
      padding: 20
    }

    var styleButton = { outline: 0 }

    return (
      <div style={styleActions}>
        <ButtonCircle title='Previous'
          style={styleButton}
          size={48}
          color='white'
          backgroundColor='#666'
          onClick={this._prev} >
          <Icon name={'previous'} width={'2em'} height={'2em'}/>
        </ButtonCircle>

        { this.state.isPlaying ?
          <ButtonCircle
            title='Pause'
            style={styleButton}
            size={48}
            color='white'
            backgroundColor='#666'
            onClick={this._pause}>
            <Icon name={'pause'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        :
          <ButtonCircle
            title='Play'
            style={styleButton}
            size={48}
            color='white'
            backgroundColor='#666'
            onClick={this._play}>
            <Icon name={'play'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        }

        <ButtonCircle
          title='Next'
          style={styleButton}
          size={48}
          color='white'
          backgroundColor='#666'
          onClick={this._next}>
          <Icon name={'next'} width={'2em'} height={'2em'}/>
        </ButtonCircle>
      </div>
    )
  },

  _pause: function () {
    var player = this.state.audioPlayer
    if (!player) return

    player.pause()
    this.setState({isPlaying: false})
  },

  _play: function () {
    var player = this.state.audioPlayer
    if (!player) return

    player.play()
    this.setState({isPlaying: true})
  },

  _prev: function () {
    var idx = this.state.idxTrack - 1
    if (idx < 0) idx = this.state.tracks.length - 1
    this._loadIdx(idx)
    if (this.state.isPlaying) this._play()
  },

  _next: function () {
    var idx = (this.state.idxTrack + 1) % this.state.tracks.length
    this._loadIdx(idx)
    if (this.state.isPlaying) this._play()
  },

  _loadIdx: function (idx) {
    var player = this.state.audioPlayer
    var track = this.state.tracks[idx]
    if (!track) return

    var url = track.url

    if (player) {
      player.src(url)
    } else {
      player = playAudio(url)
      player.on('ended', this.trackEnded)
      player.on('timeupdate', this.timeupdate)
      this.setState({audioPlayer: player})
    }

    this.setState({idxTrack: idx})
  },

  trackEnded: function (evt) {
    var idxNext = this.state.idxTrack + 1
    if ( idxNext >= this.state.tracks.length ) {
      return this.props.onFinish()
    }

    this._next()
  },

  timeupdate: function (evt) {
    var audio = evt.srcElement
    this.setState({
      currentTime: audio.currentTime,
      duration: audio.duration
    })
  },

  _setProgress: function (evt) {
    var box = evt.target.getBoundingClientRect()

    var mx = evt.clientX
    var bx = mx - box.left
    var rx = bx / box.width

    if (!this.state.duration) return

    var time = rx * this.state.duration
    this.state.audioPlayer.element().currentTime = time
  }
})
