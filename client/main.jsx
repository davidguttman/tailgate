var React = require('react')
var Directory = require('./directory.jsx')
var Player = require('./player.jsx')

var Main = module.exports = React.createClass({
  render: function () {
    var mainStyle = {
      fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif',
      display: 'flex',
      justifyContent: 'space-between',
      padding: 20
    }

    return (
      <div style={mainStyle}>
        <Directory path={this.props.path} />
        <Player />
      </div>
    )
  }
})
