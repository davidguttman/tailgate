aa = require '../album-art'

module.exports = (req, res) ->
  query = req.query.q

  aa query, (err, result) ->
    res.json 200, url: result
