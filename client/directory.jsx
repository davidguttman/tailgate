var React = require('react')
var resolve = require('path').resolve
var normalize = require('path').normalize
var api = require('./api')

var Directory = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      path: '/'
    }
  },

  getInitialState: function() {
    return {
      _error: false,
      files: []
    }
  },

  componentWillMount: function() {
    var self = this

    api.getPath(this.props.path, function (err, files) {
      if (err) return self.setState({_error: err})

      self.setState({files: files})
    })
  },

  render: function () {
    var self = this
    var parentDir = this.props.path.replace(/^\//, '').length ?
      normalize(resolve(this.props.path, '..')) :
      null

    return (
      <div>
        { parentDir ? <a href={'#/' + parentDir}>Up</a> : '' }
        { this.state.files.map(function (file) {
          if (file.isDirectory) {
            return self.renderDirectory(file)
          } else {
            return self.renderFile(file)
          }
        }) }
      </div>
    )
  },

  renderDirectory: function (dir) {
    return (
      <div key={dir.name}>
        <a href={'#/' + dir.path}>{dir.name}</a>
      </div>
    )
  },

  renderFile: function (file) {
    return (
      <div key={file.name}>
        <a href={file.url}>{file.name}</a>
      </div>
    )
  }
})
