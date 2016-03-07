var h = require('hyperscript')
var auth = require('./auth')
var directory = require('./directory')

init()

function init () {
  var main = h('.main')
  document.body.appendChild(main)

  window.addEventListener('hashchange', runRoutes.bind(null, main))

  runRoutes(main)
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

  directory(el, appState)
}
