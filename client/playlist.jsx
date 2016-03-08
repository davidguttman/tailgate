var React = require('react')
var rebass = require('rebass')
var Icon = require('react-geomicons')

var Card = rebass.Card
var ButtonCircle = rebass.ButtonCircle

var Playlist = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      playlist: [],
      width: 256,
      onSelect: function () {},
      onRemove: function () {}
    }
  },

  getInitialState: function() {
    return {
      selected: (this.props.playlist[0] || {}).path,
      _removeMode: false
    }
  },

  componentWillReceiveProps: function (nextProps) {
    if (this.state.selected) return
    this.setState({selected: (nextProps.playlist[0] || {}).path})
  },

  render: function () {
    if (!this.props.playlist.length) return <div />

    var self = this

    return (
      <div>
        { this.props.playlist.map(function (dir) {
          var isSelected = dir.path === self.state.selected

          return (
            <Card
              key={dir.path}
              style={{cursor: 'pointer', position: 'relative'}}
              width={self.props.width}
              backgroundColor={ isSelected ? '#666' : undefined}
              color={ isSelected ? 'white' : undefined}
              onClick={self._select.bind(null, dir)}>
              <div>{[dir.artist, dir.album].join(' - ')}</div>

              { !self.state._removeMode ? '' : self.renderRemove(dir) }
            </Card>
          )
        }) }

        <div style={{textAlign: 'center'}}>
          <ButtonCircle
            onClick={this._toggleRemoveMode}
            backgroundColor={ this.state._removeMode ? '#444' : '#aaa'}
            style={{outline: 0}} >
            <Icon name='cog' />
          </ButtonCircle>
        </div>
      </div>
    )
  },

  renderRemove: function (dir) {
    var styleButton = { outline: 0 }

    var styleSelect = {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-around',
      position: 'absolute',
      background: 'rgba(255,255,255,0.8)',
      color: 'white',
      top: 0,
      left: 0,
      bottom: 0,
      right: 0
    }

    return (
      <div style={styleSelect}>
        <ButtonCircle
          title='Remove'
          style={styleButton}
          color='white'
          backgroundColor='#666'
          onClick={this._remove.bind(null, dir)} >
          <Icon name={'close'} />
        </ButtonCircle>
      </div>
    )
  },

  _select: function (dir) {
    if (dir.path === this.state.selected) return
    this.setState({selected: dir.path})
    this.props.onSelect(dir)
  },

  _remove: function (dir) {
    if (dir.path === this.state.selected) {
      this.setState({selected: null})
    }

    this.props.onRemove(dir)
  },

  _toggleRemoveMode: function () {
    this.setState({_removeMode: !this.state._removeMode})
  }

})
