var React = require('react')
var rebass = require('rebass')

var Card = rebass.Card

var Playlist = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      playlist: [],
      width: 256,
      onSelect: function () {}
    }
  },

  getInitialState: function() {
    return {
      selected: (this.props.playlist[0] || {}).path
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
              style={{cursor: 'pointer'}}
              width={self.props.width}
              backgroundColor={ isSelected ? '#666' : undefined}
              color={ isSelected ? 'white' : undefined}
              onClick={self._select.bind(null, dir)}>
              <div>{[dir.artist, dir.album].join(' - ')}</div>
            </Card>
          )
        }) }
      </div>
    )
  },

  _select: function (dir) {
    if (dir.path === this.state.selected) return
    this.setState({selected: dir.path})
    this.props.onSelect(dir)
  }
})
