var React = require('react')
var Directory = require('./directory.jsx')
var Player = require('./player.jsx')

var Main = module.exports = React.createClass({
  render: function () {
    return (
      <div>
        <Player />
        <Directory path={this.props.path} />
      </div>
    )
  }
})
