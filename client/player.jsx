var React = require('react')
var rebass = require('rebass')
var moment = require('moment')
var Icon = require('react-geomicons')

var Text = rebass.Text
var Card = rebass.Card
var Heading = rebass.Heading
var Progress = rebass.Progress
var CardImage = rebass.CardImage
var ButtonCircle = rebass.ButtonCircle

var Player = module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      width: 256,
      trackTitle: '01 - Israel',
      artist: 'Bill Evans Trio',
      album: 'Explorations',
      time: 50,
      duration: 180,
      coverArt: 'http://dgshare.objects.dreamhost.com/music/Bill%20Evans%20Trio%20-%20Explorations%20-%201961%20%28Mono%20Vinyl%20MP3%20V0%29/folder.jpg'
    }
  },

  getInitialState: function() {
    return {
      isPlaying: false
    }
  },

  render: function () {
    var fmtString = this.props.duration > 3600 ? 'H:mm:ss' : 'mm:ss'
    var progress = this.props.time / this.props.duration
    var duration = moment(this.props.duration * 1000).utc().format(fmtString)
    var time = moment(this.props.time * 1000).utc().format(fmtString)

    var styleTime = {
      display: 'flex',
      justifyContent: 'space-between',
      fontSize: '70%',
      marginTop: -15
    }

    return (
      <div>
        <Card width={this.props.width}>

          <CardImage src={this.props.coverArt} />

          <div style={{textAlign: 'center', padding: 20}}>
            <Heading
              level={2}
              size={3} >
              {this.props.trackTitle}
            </Heading>

            <Text>
              {this.props.artist}
            </Text>
          </div>

          <Progress
            color={'primary'}
            value={progress} >
          </Progress>

          <div style={styleTime}>
            <span> {time} </span>
            <span> {duration} </span>
          </div>

          { this.renderActions() }
        </Card>
      </div>
    )
  },

  renderActions: function () {
    var styleActions = {
      display: 'flex',
      justifyContent: 'space-between',
      padding: 20
    }

    return (
      <div style={styleActions}>
        <ButtonCircle title='Previous' size={48}>
          <Icon name={'previous'} width={'2em'} height={'2em'}/>
        </ButtonCircle>

        { this.state.isPlaying ?
          <ButtonCircle title='Pause' size={48} onClick={this._pause}>
            <Icon name={'pause'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        :
          <ButtonCircle title='Play' size={48} onClick={this._play}>
            <Icon name={'play'} width={'2em'} height={'2em'}/>
          </ButtonCircle>
        }

        <ButtonCircle title='Next' size={48}>
          <Icon name={'next'} width={'2em'} height={'2em'}/>
        </ButtonCircle>
      </div>
    )
  },

  _pause: function () {
    this.setState({isPlaying: false})
  },

  _play: function () {
    this.setState({isPlaying: true})
  }
})
