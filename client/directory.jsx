var _ = require('lodash')
var React = require('react')
var rebass = require('rebass')
var resolve = require('path').resolve
var normalize = require('path').normalize
var Icon = require('react-geomicons')
var api = require('./api')

var Text = rebass.Text
var Card = rebass.Card
var Radio = rebass.Radio
var Heading = rebass.Heading
var Container = rebass.Container
var ButtonCircle = rebass.ButtonCircle

var Directory = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      path: '/',
      onAdd: function () {},
      height: undefined,
      dirWidth: 320,
      width: 500,
      playlist: []
    }
  },

  getInitialState: function() {
    return {
      _error: false,
      files: [],
      directories: [],
      sortBy: 'mtime'
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

    var style = {
      height: this.props.height,
      width: this.props.width,
      overflow: 'auto',
      paddingTop: 25
    }

    var styleList = {
      display: 'flex',
      flexWrap: 'wrap',
      alignItems: 'center',
      justifyContent: 'center',
      alignContent: 'center'
    }

    var styleButton = { outline: 0 }

    var directories = _.sortBy(this.state.directories, this.state.sortBy)
    if (this.state.sortBy === 'mtime') directories.reverse()

    return (
      <div style={style}>
        { !parentDir ? '' :
          <ButtonCircle
            title='Up'
            style={styleButton}
            size={48}
            color='white'
            backgroundColor='#666'
            onClick={this._navigate.bind(this, parentDir)} >
            <Icon name={'chevronUp'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        }

        <Container style={{width: 200, marginBottom: 20}}>
          <Radio
            name='sortBy'
            value='name'
            checked={this.state.sortBy === 'name'}
            onChange={this._changeSort}
            label='By Name' />

          <Radio
            name='sortBy'
            value='mtime'
            checked={this.state.sortBy === 'mtime'}
            onChange={this._changeSort}
            label='By Time' />
        </Container>

        <div style={styleList}>
          { this.state.files.map(function (file) {
            return self.renderFile(file)
          }) }
        </div>

        <div style={styleList}>
          { directories.map(function (file) {
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

    var isPlaylist = false
    for (var i = 0; i < this.props.playlist.length; i++) {
      if (this.props.playlist[i].name === dir.name) {
        isPlaylist = true
        break
      }
    }

    var style = {
      marginLeft: 5,
      marginRight: 5,
      cursor: 'pointer'
    }

    var styleDir = {
      position: 'relative',
      marginBottom: 5,
      marginTop: 5,
      minHeight: 74
    }

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

    if (isPlaylist) { styleDir.background = 'rgba(0,50,0,0.5)' }

    var styleButton = { outline: 0 }

    return (
      <div
        key={dir.name}
        title={dir.name}
        style={style}
        onClick={this._select.bind(this, dir)} >

        <Card width={this.props.dirWidth} style={styleDir}>
          <Heading
            level={2}
            size={4} >
            {dir.artist}
          </Heading>
          <Text>
            {albumText}
          </Text>

          { !isSelected ? '' :
            <div style={styleSelect} onClick={this._select.bind(this, dir)} >
              <ButtonCircle
                title='Navigate'
                style={styleButton}
                size={48}
                color='white'
                backgroundColor='#666'
                onClick={this._navigate.bind(this, dir.path)} >
                <Icon name={'external'} width={'2em'} height={'2em'}/>
              </ButtonCircle>

              <ButtonCircle
                title='Add To Playlist'
                style={styleButton}
                color='white'
                backgroundColor='#666'
                onClick={this._add.bind(null, dir)}
                size={48} >
                <Icon name={'list'} width={'2em'} height={'2em'}/>
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
    if (this.state.selected === dir.name) {
      this.setState({selected: null})
    } else {
      this.setState({selected: dir.name})
    }
  },

  _navigate: function (path) {
    window.location.hash = '#/' + path
  },

  _add: function (dir) {
    this._select(dir)
    this.props.onAdd(dir)
  },

  _changeSort: function (evt) {
    var change = {}
    change[evt.target.name] = evt.target.value
    this.setState(change)
  }
})
