email = (require 'emailjs').server.connect
  host: 'localhost'
  port: 25
  domain: 'localhost'

module.exports = ({to, from, subject, text}, cb) ->
  email.send
    to:      to
    from:    from
    subject: subject
    text:    text
  , cb
