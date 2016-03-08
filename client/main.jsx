var React = require('react')
var Directory = require('./directory.jsx')
var Player = require('./player.jsx')
var Playlist = require('./playlist.jsx')

var Main = module.exports = React.createClass({
  getInitialState: function() {
    return {
      path: window.location.hash.replace('#/', ''),
      playlist: [],
      width: window.innerWidth,
      height: window.innerHeight,
      idxSelected: 0
    }
  },

  componentWillMount: function() {
    var self = this
    window.addEventListener('hashchange', function () {
      var path = window.location.hash.replace('#/', '')
      self.setState({path: path})
    })
    var playlist = JSON.parse(window.localStorage.tgPlaylist || '[]')
    this.setState({playlist: playlist})

    window.addEventListener('resize', function () {
      self.setState({width: window.innerWidth, height: window.innerHeight})
    })
  },

  render: function () {
    var mainStyle = {
      display: 'flex',
      justifyContent: 'space-between'
    }

    var totalWidth = this.state.width
    var totalHeight = this.state.height

    var playerWidth = 300
    var dirWidth = totalWidth - playerWidth

    var album = this.state.playlist[this.state.idxSelected]
    var albumPath = album ? album.path : null

    return (
      <div style={mainStyle}>
        <Directory
          key={'d' + this.state.path}
          path={this.state.path}
          width={dirWidth}
          height={totalHeight}
          onAdd={this._addAlbum} />

        <div style={{height: totalHeight, paddingTop: 10}}>
          <Player
            width={playerWidth}
            albumPath={albumPath}
            onFinish={this._onAlbumFinish} />
          <Playlist
            width={playerWidth}
            playlist={this.state.playlist}
            onSelect={this._selectAlbum}
            onRemove={this._removeAlbum} />
        </div>
      </div>
    )
  },

  _addAlbum: function (dir) {
    var playlist = []
    this.state.playlist.forEach(function (item) {
      if (dir.path !== item.path) playlist.push(item)
    })

    playlist.push(dir)
    this.setState({playlist: playlist})
    window.localStorage.tgPlaylist = JSON.stringify(playlist)
  },

  _selectAlbum: function (selected) {
    var idxSelected = 0
    this.state.playlist.forEach(function (dir, i) {
      if (dir.path === selected.path) idxSelected = i
    })
    this.setState({idxSelected: idxSelected})
  },

  _removeAlbum: function (dir) {
    var playlist = []
    var iRem = 0
    this.state.playlist.forEach(function (item, i) {
      if (dir.path !== item.path) return playlist.push(item)
      iRem = i
    })

    var idxSelected = this.state.idxSelected
    if (iRem <= idxSelected) idxSelected -= 1
    if (idxSelected < 0) idxSelected = 0

    this.setState({playlist: playlist, idxSelected: idxSelected})
    window.localStorage.tgPlaylist = JSON.stringify(playlist)
  },

  _onAlbumFinish: function () {
    var idx = (this.state.idxSelected + 1) % this.state.playlist.length
    this.setState({idxSelected: idx})
  }

})
