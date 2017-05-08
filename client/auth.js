var Authentic, auth, onLogin

var Authentic = require('authentic-ui')

var auth = Authentic({
  server: 'https://authentic.thhis.com',
  links: {
    signup: '#/signup',
    login: '#/login',
    changePasswordRequest: '#/change-password-request'
  }
})

module.exports = {
  auth: auth,
  routes: {
    login: function (el) {
      el.appendChild(auth.login(onLogin))
    },

    signup: function (el) {
      var urlTemplate = window.location.origin + '#/confirm/<%= email %>/<%= confirmToken %>'
      var bodyTemplate = ['<h1>Welcome to Tailgate</h1>', '<p>Thanks for signing up! Please ', '<a href="' + urlTemplate + '">confirm your account</a> ', 'to continue.', '</p>'].join('')
      var opts = {
        from: 'Tailgate <accounts@thhis.com>',
        subject: 'Welcome to Tailgate',
        confirmUrl: urlTemplate,
        provide: { bodyTemplate: bodyTemplate }
      }

      el.appendChild(auth.signup(opts))
    },

    confirm: function (el) {
      var params = window.location.hash.split('/').slice(-2)
      var email = params[0]
      var confirmToken = params[1]
      var opts = {
        email: email,
        confirmToken: confirmToken,
        confirmDelay: 5000
      }

      el.appendChild(auth.confirm(opts, onLogin))
    },

    changePasswordRequest: function (el) {
      var urlTemplate = window.location.origin + '#/change-password/<%= email %>/<%= changeToken %>'
      var bodyTemplate = ['<h1>Tailgate Password Change</h1>', '<p>We received your request to change your password. Please ', '<a href="' + urlTemplate + '">choose a new password</a> ', 'to continue.', '</p>'].join('')
      var opts = {
        from: 'Tailgate <accounts@thhis.com>',
        subject: 'Change your Tailgate password',
        changeUrl: urlTemplate,
        provide: { bodyTemplate: bodyTemplate }
      }
      el.appendChild(auth.changePasswordRequest(opts))
    },

    changePassword: function (el) {
      var params = window.location.hash.split('/').slice(-2)
      var email = params[0]
      var changeToken = params[1]
      var opts = {
        email: email,
        changeToken: changeToken,
        confirmDelay: 5000
      }
      el.appendChild(auth.changePassword(opts, onLogin))
    },

    logout: function (el) {
      auth.logout()
      setTimeout(function() {
        window.location.hash = '/login'
      }, 2000)
    }
  }
}

function onLogin (err) {
  if (err) return console.error(err)

  setTimeout(function() {
    window.location.hash = '/'
  }, 2000)
}
