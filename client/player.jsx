var React = require('react')
var rebass = require('rebass')
var moment = require('moment')
var Icon = require('react-geomicons')
var playAudio = require('play-audio')

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
    var albumName = albumPath.split('/').slice(-1)[0]
    var info = api.parseName(albumPath)

    this.setState({_isLoading: true})
    api.getPath(albumPath, function (err, files) {
      if (err) return console.error(err)

      var tracks = []
      var images = []

      files.forEach(function (file) {
        if (['mp3', 'm4a'].indexOf(file.ext) >= 0) tracks.push(file)
        if (['png', 'jpg'].indexOf(file.ext) >= 0) images.push(file)
      })

      var coverArt
      for (var i = images.length - 1; i >= 0; i--) {
        coverArt = images[i].url
        if (images[i].name === 'folder.jpg') break
        if (images[i].name === 'cover.jpg') break
      }

      self.setState({
        tracks: tracks,
        coverArt: coverArt,
        albumName: info.album,
        artist: info.artist,
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
    if (!this.state.tracks.length) return <div style={{height: 256}} />

    return (
      <Container style={{paddingTop: 25}}>
        { this.state._isLoading ? <Loading /> : this.renderPlayer() }
      </Container>
    )
  },

  renderPlayer: function () {
    var track = this.state.tracks[this.state.idxTrack] || {name: '', ext: 'mp3'}
    var trackName = track.name.replace('.' + track.ext, '')

    return (
      <Card>

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
    if ( (this.state.idxTrack + 1) >= this.state.tracks.length ) {
      this.props.onFinish()
    }

    this._next()
  },

  timeupdate: function (evt) {
    var audio = evt.srcElement
    this.setState({
      currentTime: audio.currentTime,
      duration: audio.duration
    })
  }
})
