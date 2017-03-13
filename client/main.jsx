var React = require('react')
var rebass = require('rebass')
var Icon = require('react-geomicons')

var Player = require('./player.jsx')
var Directory = require('./directory.jsx')
var Playlist = require('./playlist.jsx')

var Container = rebass.Container
var ButtonCircle = rebass.ButtonCircle

var Main = module.exports = React.createClass({
  getInitialState: function() {
    return {
      path: window.location.hash.replace('#/', ''),
      playlist: [],
      width: window.innerWidth,
      height: window.innerHeight,
      idxSelected: 0,
      _ui: 'player'
    }
  },

  componentWillMount: function() {
    var self = this
    window.addEventListener('hashchange', function () {
      var path = window.location.hash.replace('#/', '')
      self.setState({path: path})
    })
    var playlist = JSON.parse(window.localStorage.tgPlaylist || '[]')
    var idxSelected = JSON.parse(window.localStorage.tgIdxSelected || '0')
    this.setState({playlist: playlist, idxSelected: idxSelected})

    window.addEventListener('resize', function () {
      self.setState({width: window.innerWidth, height: window.innerHeight})
    })
  },

  render: function () {
    var totalWidth = this.state.width
    var totalHeight = this.state.height

    var playerWidth = 300
    var dirWidth = totalWidth - playerWidth
    var dirHeight = totalHeight

    var isMobile = false
    if (totalWidth < 700) {
      isMobile = true
      dirWidth = totalWidth
      dirHeight = undefined
    }

    var album = this.state.playlist[this.state.idxSelected]
    var albumPath = album ? album.path : null

    var mainStyle = {
      display: 'flex',
      justifyContent: 'space-between'
    }

    var styleUISelect = {
      display: 'flex',
      justifyContent: 'space-around',
      paddingTop: 25
    }

    var dirStyle = {}
    var playerStyle = {height: totalHeight, width: playerWidth}

    if (isMobile) {
      if (this.state._ui !== 'directory') dirStyle.display = 'none'
      if (this.state._ui !== 'player') playerStyle.display = 'none'
    }

    return (
      <div>
        { !isMobile ? '' :
          <div style={styleUISelect}>
            <ButtonCircle title='Albums' onClick={this._setUIDirectory}
              color='white'
              backgroundColor={this.state._ui == 'directory' ? '#aaa' : '#444'}>
              <Icon name={'folder'} />
            </ButtonCircle>

            <ButtonCircle title='Music Player' onClick={this._setUIPlayer}
              color='white'
              backgroundColor={ this.state._ui === 'player' ? '#aaa' : '#444'} >
              <Icon name={'musicNote'} />
            </ButtonCircle>
          </div>
        }

        <div style={mainStyle}>

          <div style={dirStyle}>
            <Directory
              key={'d' + this.state.path}
              path={this.state.path}
              width={dirWidth}
              dirWidth={isMobile ? dirWidth - 20 : undefined}
              height={dirHeight}
              playlist={this.state.playlist}
              onAdd={this._addAlbum} />
          </div>

          <Container style={playerStyle}>
            <Player
              albumPath={albumPath}
              onFinish={this._onAlbumFinish} />
            <Playlist
              idxSelected={this.state.idxSelected}
              playlist={this.state.playlist}
              onSelect={this._selectAlbum}
              onRemove={this._removeAlbum} />
          </Container>
        </div>
      </div>
    )
  },

  _addAlbum: function (dir) {
    var playlist = []
    this.state.playlist.forEach(function (item) {
      if (dir.path !== item.path) playlist.push(item)
    })

    playlist.unshift(dir)
    this.setState({playlist: playlist})
    window.localStorage.tgPlaylist = JSON.stringify(playlist)
  },

  _selectAlbum: function (selected) {
    var idxSelected = 0
    this.state.playlist.forEach(function (dir, i) {
      if (dir.path === selected.path) idxSelected = i
    })
    this.setState({idxSelected: idxSelected})
    window.localStorage.tgIdxSelected = JSON.stringify(idxSelected)
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
    window.localStorage.tgIdxSelected = JSON.stringify(idxSelected)
  },

  _onAlbumFinish: function () {
    var idx = (this.state.idxSelected + 1) % this.state.playlist.length
    this.setState({idxSelected: idx})
    window.localStorage.tgIdxSelected = JSON.stringify(idx)
  },

  _setUIPlayer: function () {
    this.setState({_ui: 'player'})
  },

  _setUIDirectory: function () {
    this.setState({_ui: 'directory'})
  }

})
