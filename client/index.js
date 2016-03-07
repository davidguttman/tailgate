var h = require('hyperscript')
var React = require('react')
var ReactDOM = require('react-dom')

var auth = require('./auth')
var Main = require('./main.jsx')

init()

function init () {
  var app = h('.app')
  document.body.appendChild(app)

  window.addEventListener('hashchange', runRoutes.bind(null, app))

  runRoutes(app)
}

function runRoutes (el) {
  var appState = window.location.hash.replace('#/', '')
  el.innerHTML = ''

  if (appState === 'login') return auth.routes.login(el)
  if (appState === 'signup') return auth.routes.signup(el)
  if (appState === 'logout') return auth.routes.logout(el)
  if (appState.match(/^confirm/)) return auth.routes.confirm(el)
  if (appState.match(/^change-password/)) return auth.routes.changePassword(el)
  if (appState === 'change-password-request') {
    return auth.routes.changePasswordRequest(el)
  }

  if (!auth.auth.authToken()) return window.location.hash = '/login'

  mainRoute(el, appState)
}

var loaded
function mainRoute (el, appState) {
  if (loaded) return el.appendChild(loaded)

  var main = h('.main')
  el.appendChild(main)
  ReactDOM.render(React.createElement(Main), main)
  loaded = main
}
