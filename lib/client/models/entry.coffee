moment = require 'moment'

module.exports = Entry = Backbone.Model.extend
  created: ->
    ctime = @get 'ctime'
    moment(ctime).fromNow()