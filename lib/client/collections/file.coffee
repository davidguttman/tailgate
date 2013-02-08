moment = require 'moment'

module.exports = Backbone.Model.extend
  created: ->
    ctime = @get 'ctime'
    moment(ctime).fromNow()

  upvote: ->
    path = @get 'path'
    $.get "/api/upvote?path=#{escape path}"
    @set vote: 1

  downvote: ->
    path = @get 'path'
    $.get "/api/downvote?path=#{escape path}"
    @set vote: -1

  clearvote: ->
    path = @get 'path'
    $.get "/api/clearvote?path=#{escape path}"
    @set vote: 0