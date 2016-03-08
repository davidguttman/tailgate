var React = require('react')
var Directory = require('./directory.jsx')
var Player = require('./player.jsx')
var Playlist = require('./playlist.jsx')

var Main = module.exports = React.createClass({
  getInitialState: function() {
    return {
      path: window.location.hash.replace('#/', ''),
      playlist: [],
      idxSelected: 0
    }
  },

  componentWillMount: function() {
    var self = this
    window.addEventListener('hashchange', function () {
      var path = window.location.hash.replace('#/', '')
      self.setState({path: path})
    })
  },

  render: function () {
    var mainStyle = {
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
      display: 'flex',
      color: '#111',
      justifyContent: 'space-between',
      padding: 20
    }

    var album = this.state.playlist[this.state.idxSelected]
    var albumPath = album ? album.path : null

    return (
      <div style={mainStyle}>
        <Directory
          key={'d' + this.state.path}
          path={this.state.path}
          onAdd={this._addAlbum} />

        <div style={{marginRight: 20}}>
          <Player albumPath={albumPath} onFinish={this._onAlbumFinish} />
          <Playlist playlist={this.state.playlist} onSelect={this._selectAlbum} />
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
  },

  _selectAlbum: function (selected) {
    var idxSelected = 0
    this.state.playlist.forEach(function (dir, i) {
      if (dir.path === selected.path) idxSelected = i
    })
    this.setState({idxSelected: idxSelected})
  },

  _onAlbumFinish: function () {
    var idx = (this.state.idxSelected + 1) % this.state.playlist.length
    this.setState({idxSelected: idx})
  }

})
