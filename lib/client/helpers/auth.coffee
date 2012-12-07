module.exports = (token) ->
  onSuccess = (data) ->
    console.log "Login Successful", data
    window.location = data

  opts =
    url: "/login"
    success: onSuccess
    data:
      token: token

    type: "POST"

  $.ajax opts