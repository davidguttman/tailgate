bean = require 'bean'
jsonist = require 'jsonist'

api = require '../api.coffee'
styles = require './style.scss'
template = require './template.jade'

module.exports = ->
  view = new View arguments...
  document.body.appendChild view.el

View = (@opts={}) ->
  @el = document.createElement 'div'
  @setEvents()

  @mode = 'request'

  @render()
  return this

View::setEvents = ->
  events = [
    ['submit', 'form.step1', @getCode]
    ['submit', 'form.step2', @login]
  ]

  for event in events
    [type, selector, handler] = event
    bean.on @el, type, selector, handler.bind this

View::render = ->
  @el.innerHTML = template mode: @mode
  return this

View::getCode = (evt) ->
  evt.preventDefault()

  email = @el.querySelector('.email').value
  @email = email
  api.getCode email, (err, res) =>
    return console.error err if err
    if res.success
      @mode = 'enter'
      @render()

View::login = (evt) ->
  evt.preventDefault()

  code = @el.querySelector('.code').value
  api.login @email, code, (err, res) =>
    console.error err if err
    if res.success
      window.location.reload()
    else
      @mode = 'request'
      @render()