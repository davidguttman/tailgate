moment = require 'moment'

module.exports = Entry = Backbone.Model.extend
  created: ->
    atime = @get 'ctime'
    moment(atime).fromNow()