moment = require 'moment'

module.exports = Backbone.Model.extend
  created: ->
    ctime = @get 'ctime'
    moment(ctime).format 'MM/YY'

  upvote: ->
    path = @get 'path'
    $.get "/api/upvote?path=#{encodeURIComponent path}"
    @set vote: 1

  downvote: ->
    path = @get 'path'
    $.get "/api/downvote?path=#{encodeURIComponent path}"
    @set vote: -1

  clearvote: ->
    path = @get 'path'
    $.get "/api/clearvote?path=#{encodeURIComponent path}"
    @set vote: 0