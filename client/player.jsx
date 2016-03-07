var React = require('react')
var rebass = require('rebass')
var moment = require('moment')
var Icon = require('react-geomicons')
var api = require('./api')

var Text = rebass.Text
var Card = rebass.Card
var Heading = rebass.Heading
var Progress = rebass.Progress
var CardImage = rebass.CardImage
var ButtonCircle = rebass.ButtonCircle

var Player = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      width: 256,
      albumPath: '/Firefly - OST',
      time: 50,
      duration: 180
    }
  },

  getInitialState: function() {
    return {
      albumName: null,
      isPlaying: false,
      tracks: [],
      coverArt: null,
      idxTrack: 0
    }
  },

  componentWillMount: function() {
    var self = this
    var albumPath = this.props.albumPath
    var albumName = albumPath.split('/').slice(-1)[0]

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
      }

      self.setState({
        tracks: tracks,
        coverArt: coverArt,
        albumName: albumName
      })
    })
  },

  render: function () {
    var track = this.state.tracks[this.state.idxTrack] || {name: '', ext: 'mp3'}
    var trackName = track.name.replace('.' + track.ext, '')

    var fmtString = this.props.duration > 3600 ? 'H:mm:ss' : 'mm:ss'
    var progress = this.props.time / this.props.duration
    var duration = moment(this.props.duration * 1000).utc().format(fmtString)
    var time = moment(this.props.time * 1000).utc().format(fmtString)

    var styleTime = {
      display: 'flex',
      justifyContent: 'space-between',
      fontSize: '70%',
      marginTop: -15
    }

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

          <Progress
            color={'primary'}
            value={progress} >
          </Progress>

          <div style={styleTime}>
            <span> {time} </span>
            <span> {duration} </span>
          </div>

          { this.renderActions() }
        </Card>
      </div>
    )
  },

  renderActions: function () {
    var styleActions = {
      display: 'flex',
      justifyContent: 'space-between',
      padding: 20
    }

    return (
      <div style={styleActions}>
        <ButtonCircle title='Previous' size={48} onClick={this._prev}>
          <Icon name={'previous'} width={'2em'} height={'2em'}/>
        </ButtonCircle>

        { this.state.isPlaying ?
          <ButtonCircle title='Pause' size={48} onClick={this._pause}>
            <Icon name={'pause'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        :
          <ButtonCircle title='Play' size={48} onClick={this._play}>
            <Icon name={'play'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        }

        <ButtonCircle title='Next' size={48} onClick={this._next}>
          <Icon name={'next'} width={'2em'} height={'2em'}/>
        </ButtonCircle>
      </div>
    )
  },

  _pause: function () {
    this.setState({isPlaying: false})
  },

  _play: function () {
    this.setState({isPlaying: true})
  },

  _prev: function () {
    var idx = this.state.idxTrack - 1
    if (idx < 0) idx = this.state.tracks.length - 1
    this.setState({idxTrack: idx})
  },

  _next: function () {
    var idx = (this.state.idxTrack + 1) % this.state.tracks.length
    this.setState({idxTrack: idx})
  }
})
