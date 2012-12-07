moment = require 'moment'

module.exports = Entry = Backbone.Model.extend
  created: ->
    atime = @get 'atime'
    moment(atime).fromNow()