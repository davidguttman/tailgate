var React = require('react')
var rebass = require('rebass')
var resolve = require('path').resolve
var normalize = require('path').normalize
var api = require('./api')

var Text = rebass.Text
var Card = rebass.Card
var Heading = rebass.Heading

var Directory = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      path: '/'
    }
  },

  getInitialState: function() {
    return {
      _error: false,
      files: [],
      directories: []
    }
  },

  componentWillMount: function() {
    var self = this

    api.getPath(this.props.path, function (err, items) {
      if (err) return self.setState({_error: err})

      var dirs = []
      var files = []

      items.forEach(function (item) {
        if (item.isDirectory) return dirs.push(item)
        files.push(item)
      })

      self.setState({files: files, directories: dirs})
    })
  },

  render: function () {
    var self = this
    var parentDir = this.props.path.replace(/^\//, '').length ?
      normalize(resolve(this.props.path, '..')) :
      null

    var styleList = {
      display: 'flex',
      flexWrap: 'wrap',
      alignContent: 'flex-start'
    }

    return (
      <div>
        { parentDir ? <a href={'#/' + parentDir}>Up</a> : '' }

        <div style={styleList}>
          { this.state.files.map(function (file) {
            return self.renderFile(file)
          }) }
        </div>

        <div style={styleList}>
          { this.state.directories.map(function (file) {
            return self.renderDirectory(file)
          }) }
        </div>
      </div>
    )
  },

  renderDirectory: function (dir) {
    var info = parseName(dir.name)
    var albumText = info.album
    if (info.year) albumText += ' (' + info.year + ')'

    // <a href={'#/' + dir.path}>
    return (
      <div
        key={dir.name}
        style={{padding: 5, cursor: 'pointer'}}
        onClick={this._changeDir.bind(this, dir)} >

        <Card width={256}>
          <Heading
            level={2}
            size={3} >
            {info.artist}
          </Heading>
          <Text>
            {albumText}
          </Text>
        </Card>
      </div>
    )
  },

  renderFile: function (file) {
    return (
      <div
        key={file.name}
        style={{padding: 5, cursor: 'pointer'}} >

        <Card>
          <Heading
            level={2}
            size={5} >
            {file.name}
          </Heading>
        </Card>
      </div>
    )

    return (
      <div key={file.name}>
        <a href={file.url}>{file.name}</a>
      </div>
    )
  },

  _changeDir: function (dir) {
    window.location.hash = '#/' + dir.path
  }
})

function parseName (name) {
  var metaStart = name.length
  for (var i = 0; i < name.length; i++) {
    if (name[i] === '(' || name[i] === '[' ) {
      metaStart = i
      break
    }
  }

  var artistAlbum = name.slice(0, metaStart)
  var meta = name.slice(metaStart)

  var artist = (artistAlbum.split(' - ')[0] || '').replace(/_/g, ' ')
  var album = (artistAlbum.split(' - ')[1] || '').replace(/_/g, ' ')
  var year = (meta.match(/\d{4}/) || [])[0]

  if (!artist) {
    artist = name
    album = ''
    meta = ''
  }

  return {
    artist: artist,
    album: album,
    meta: meta,
    year: year
  }

}
