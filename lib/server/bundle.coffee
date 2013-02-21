fs         = require 'fs'
browserify = require 'browserify'
jade       = require 'jade'
uglify     = require 'uglify-js'
simpleJadeify   = require 'simple-jadeify'

{version}  = require '../../package.json'

bOpts = 
  cache: true

if process.env.NODE_ENV is 'development'
  bOpts.debug = true 
  bOpts.watch = true

if process.env.NODE_ENV is 'production'
  bOpts.filter = uglify

bundle = browserify bOpts

bundle.prepend "window.VERSION = '#{version}';"
bundle.use simpleJadeify

includes = [
  'logfix.js'
  'jquery.min.js'
  'jquery.collapse.js'
  'bootstrap.min.js'
  'soundmanager2-nodebug-jsmin.js'
  'underscore.js'
  'backbone.js'
  'list.js'
  'id3.min.js'
]

for js in includes.reverse()
  bundle.prepend fs.readFileSync __dirname + "/../client/vendor/#{js}"

bundle.prepend 'window.t0 = Date.now();'
bundle.append 'window.t1 = Date.now();'

e = console.error; console.error = ->
bundle.addEntry __dirname + '/../client/entry.coffee'
console.error = e

module.exports = bundle