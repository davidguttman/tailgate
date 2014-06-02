cheerio = require 'cheerio'
request = require 'request'

# #main_left > ul > li > div:nth-child(1) > a > img

module.exports = (query, cb) ->
  url = createUrl query
  request url, (err, res, body) ->
    $ = cheerio.load body
    img = $('#main_left > ul > li > div:nth-child(1) > a > img')
    src = img.attr("src")
    cb null, src

createUrl = (query) ->
  url = 'http://www.albumart.org/index.php?searchkey='
  url += escape query
  url += '&itempage=1&newsearch=1&searchindex=Music'
