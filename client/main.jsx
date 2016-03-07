var React = require('react')
var Directory = require('./directory.jsx')
var Player = require('./player.jsx')

var Main = module.exports = React.createClass({
  getInitialState: function() {
    return {
      path: window.location.hash.replace('#/', '')
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

    return (
      <div style={mainStyle}>
        <Directory key={'d' + this.state.path} path={this.state.path} />
        <Player albumPath={'Brian Eno & Karl Hyde - Someday World (2014) [MP3 320]'} />
      </div>
    )
  }
})
