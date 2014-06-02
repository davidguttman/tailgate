aa = require '../album-art'

module.exports = (req, res) ->
  query = req.query.q

  aa query, (err, result) ->
    console.log 'result', result
    res.send 200, "<img src='#{result}' />"
