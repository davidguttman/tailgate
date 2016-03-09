var React = require('react')
var rebass = require('rebass')

var Card = rebass.Card
var DotIndicator = rebass.DotIndicator

var Loading = module.exports = React.createClass({

  getInitialState: function() {
    return {
      _loadingTime: Date.now()
    };
  },

  componentWillMount: function() {
    var self = this
    var tsStart = Date.now()
    this.loadingInterval = setInterval(function () {
      self.setState({_loadingTime: Date.now() - tsStart})
    }, 250)
  },

  componentWillUnmount: function() {
    clearInterval(this.loadingInterval)
  },

  render: function () {
    var active = Math.floor(this.state._loadingTime / 250) % 3

    return (
      <Card style={{textAlign: 'center'}}>
        <DotIndicator length={3} active={active}/>
      </Card>
    )
  }
})
