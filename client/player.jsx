var React = require('react')
var rebass = require('rebass')
var moment = require('moment')
var Icon = require('react-geomicons')
var playAudio = require('play-audio')
var api = require('./api')

var Text = rebass.Text
var Card = rebass.Card
var Heading = rebass.Heading
var Progress = rebass.Progress
var CardImage = rebass.CardImage
var ButtonCircle = rebass.ButtonCircle
var DotIndicator = rebass.DotIndicator

var Player = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      width: 256,
      albumPath: '/Bitchin Bajas - Bitchin Bajas (2014) [MP3 V0]'
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

  componentWillMount: function() {
    var self = this
    var albumPath = this.props.albumPath
    var albumName = albumPath.split('/').slice(-1)[0]

    this._startLoading()
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
        albumName: albumName
      })
      self._stopLoading()

      self._loadIdx(0)
    })
  },

  render: function () {
    if (this.state._isLoading) return this.renderLoading()
    if (!this.state.tracks.length) return <div />

    var track = this.state.tracks[this.state.idxTrack] || {name: '', ext: 'mp3'}
    var trackName = track.name.replace('.' + track.ext, '')

    return (
      <div>
        <Card width={this.props.width}>

          {!this.state.coverArt ? '' : <CardImage src={this.state.coverArt} />}

          <div style={{textAlign: 'center', padding: 20}}>
            <Heading
              level={2}
              size={3} >
              {trackName}
            </Heading>

            <Text>
              {this.state.albumName}
            </Text>
          </div>

          { this.renderProgress() }
          { this.renderActions() }

        </Card>
      </div>
    )
  },

  renderLoading: function () {
    var active = Math.floor(this.state._loadingTime / 250) % 3
    return (
      <div>
        <Card width={this.props.width}>
          <div style={{textAlign: 'center'}}>
            <DotIndicator length={3} active={active}/>
          </div>
        </Card>
      </div>
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

    var styleButton = {
      outline: 0
    }

    return (
      <div style={styleActions}>
        <ButtonCircle title='Previous' style={styleButton} size={48} onClick={this._prev}>
          <Icon name={'previous'} width={'2em'} height={'2em'}/>
        </ButtonCircle>

        { this.state.isPlaying ?
          <ButtonCircle title='Pause' style={styleButton} size={48} onClick={this._pause}>
            <Icon name={'pause'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        :
          <ButtonCircle title='Play' style={styleButton} size={48} onClick={this._play}>
            <Icon name={'play'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        }

        <ButtonCircle title='Next' style={styleButton} size={48} onClick={this._next}>
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
    this._next()
  },

  timeupdate: function (evt) {
    var audio = evt.srcElement
    this.setState({
      currentTime: audio.currentTime,
      duration: audio.duration
    })
  },

  _startLoading: function () {
    var self = this
    this.setState({_isLoading: true})
    var tsStart = Date.now()
    this.loadingInterval = setInterval(function () {
      self.setState({_loadingTime: Date.now() - tsStart})
    }, 250)
  },

  _stopLoading: function () {
    this.setState({_isLoading: false})
    clearInterval(this.loadingInterval)
  }
})
