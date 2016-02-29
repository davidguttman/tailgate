Authentic = require 'authentic-ui'

auth = Authentic
  server: 'https://authentic.thhis.com'
  links:
    signup: '#/signup'
    login: '#/login'
    changePasswordRequest: '#/change-password-request'

module.exports =
  auth: auth
  routes:
    login: ->
      @target.innerHTML = ''
      @target.appendChild auth.login(onLogin)

    signup: ->
      urlTemplate = window.location.origin + '#/confirm/<%= email %>/<%= confirmToken %>'

      opts =
        from: 'thhis.com <accounts@thhis.com>'
        subject: 'Welcome to thhis.com'
        bodyTemplate: [
          '<h1>Welcome to thhis.com</h1>',
          '<p>Thanks for signing up! Please ',
            '<a href="' + urlTemplate + '">confirm your account</a> ',
            'to continue.',
          '</p>'
        ].join('')

      @target.innerHTML = ''
      @target.appendChild auth.signup(opts)

    confirm: ->
      params = window.location.hash.split('/').slice(-2)
      email = params[0]
      confirmToken = params[1]

      opts =
        email: email
        confirmToken: confirmToken
        confirmDelay: 5000

      @target.innerHTML = ''
      @target.appendChild auth.confirm(opts, onLogin)

    changePasswordRequest: ->
      urlTemplate = window.location.origin + '#/change-password/<%= email %>/<%= changeToken %>'
      bodyTemplate = [
        '<h1>thhis.com Password Change</h1>',
        '<p>We received your request to change your password. Please ',
          '<a href="' + urlTemplate + '">choose a new password</a> ',
          'to continue.',
        '</p>'
      ].join('')

      opts =
        from: 'thhis.com <accounts@thhis.com>'
        subject: 'Change your thhis.com password'
        bodyTemplate: bodyTemplate

      @target.innerHTML = ''
      @target.appendChild auth.changePasswordRequest(opts)

    changePassword: ->
      params = window.location.hash.split('/').slice(-2)
      email = params[0]
      changeToken = params[1]

      opts =
        email: email,
        changeToken: changeToken,
        confirmDelay: 5000

      @target.innerHTML = ''
      @target.appendChild auth.changePassword(opts, onLogin)

    logout: ->
      auth.logout()
      @target.innerHTML = 'You are logged out. Redirecting...'
      setTimeout () ->
        window.location.hash = '/login'
      , 2000

onLogin = (err) ->
  return console.error err if err
  setTimeout () ->
    window.location.hash = '/'
  , 2000

