var React = require('react')
var rebass = require('rebass')
var resolve = require('path').resolve
var normalize = require('path').normalize
var Icon = require('react-geomicons')
var api = require('./api')

var Text = rebass.Text
var Card = rebass.Card
var Heading = rebass.Heading
var ButtonCircle = rebass.ButtonCircle

var Directory = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      path: '/',
      onAdd: function () {}
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
    var albumText = dir.album
    if (dir.year) albumText += ' (' + dir.year + ')'
    var isSelected = dir.name === this.state.selected

    var style = {
      margin: 5,
      cursor: 'pointer'
    }

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

    var styleButton = { outline: 0 }

    // <a href={'#/' + dir.path}>
    return (
      <div
        key={dir.name}
        style={style}
        onClick={this._select.bind(this, dir)} >

        <Card width={256} style={{position: 'relative'}}>
          <Heading
            level={2}
            size={4} >
            {dir.artist}
          </Heading>
          <Text>
            {albumText}
          </Text>

          { !isSelected ? '' :
            <div style={styleSelect}>
              <ButtonCircle
                title='Go'
                style={styleButton}
                size={48}
                color='white'
                backgroundColor='#666'
                onClick={this._navigate.bind(this, dir.path)} >
                <Icon name={'link'} width={'2em'} height={'2em'}/>
              </ButtonCircle>

              <ButtonCircle
                title='Play'
                style={styleButton}
                color='white'
                backgroundColor='#666'
                onClick={this.props.onAdd.bind(null, dir)}
                size={48} >
                <Icon name={'play'} width={'2em'} height={'2em'}/>
              </ButtonCircle>
            </div>
          }
        </Card>
      </div>
    )
  },

  renderFile: function (file) {
    return (
      <div
        key={file.name}
        style={{paddingBottom: 10, paddingRigth: 10, cursor: 'pointer'}} >

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

  _select: function (dir) {
    this.setState({selected: dir.name})
  },

  _navigate: function (path) {
    window.location.hash = '#/' + path
  }
})
