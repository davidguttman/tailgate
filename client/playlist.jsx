var React = require('react')
var rebass = require('rebass')
var Icon = require('react-geomicons')
var api = require('./api')
var h = require('hyperscript')
var querystring = require('querystring')

var Card = rebass.Card
var Container = rebass.Container
var ButtonCircle = rebass.ButtonCircle

var Playlist = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      playlist: [],
      onSelect: function () {},
      onRemove: function () {}
    }
  },

  getInitialState: function() {
    return {
      selected: (this.props.playlist[0] || {}).path,
      shareToken: null,
      _removeMode: false
    }
  },

  componentWillReceiveProps: function (nextProps) {
    if (this.state.selected) return
    this.setState({selected: (nextProps.playlist[0] || {}).path})
  },

  componentDidMount: function() {
    var self = this
    api.getShareToken(function (err, res) {
      if (err) return console.error(err)
      self.setState({shareToken: res.shareToken})
    })
  },

  render: function () {
    if (!this.props.playlist.length) return this.renderEmpty()

    var self = this

    return (
      <Container style={{paddingBottom: 50}}>
        { this.props.playlist.map(function (dir) {
          var isSelected = dir.path === self.state.selected

          return (
            <Card
              key={dir.path}
              style={{cursor: 'pointer', position: 'relative'}}
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
            backgroundColor={ this.state._removeMode ? '#aaa' : '#444'}
            style={{outline: 0}} >
            <Icon name='cog' />
          </ButtonCircle>
        </div>
      </Container>
    )
  },

  renderEmpty: function () {
    return (
      <div style={{textAlign: 'center'}}>
        <p>Your playlist is empty</p>
        <br />
        <p>Please add an album</p>
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
      background: 'rgba(0,0,0,0.5)',
      color: 'white',
      top: 0,
      left: 0,
      bottom: 0,
      right: 0
    }

    return (
      <div style={styleSelect}>
        { !this.state.shareToken ? '' :
          <ButtonCircle
            title='Share Link'
            style={styleButton}
            color='white'
            backgroundColor='#666'
            onClick={this._link.bind(null, dir)} >
            <Icon name={'link'} />
          </ButtonCircle>
        }

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

  _link: function (dir) {
    var albumPath = dir.path
    var shareToken = this.state.shareToken

    var target = window.location.origin + '/'
    target += ['#', 'shared', shareToken, encodeURIComponent(albumPath)].join('/')

    var url = 'http://listento.thhis.com/?' + querystring.stringify({ url: target })

    var a = h('a', {href: url, target: '_blank', style: {display: 'none'}})
    document.body.appendChild(a)
    a.click()
  },

  _toggleRemoveMode: function () {
    this.setState({_removeMode: !this.state._removeMode})
  }

})
