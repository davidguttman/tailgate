fs         = require 'fs'
browserify = require 'browserify'
jade       = require 'jade'
uglify     = require 'uglify-js'

{version}  = require '../../package.json'

bOpts = 
  require:
    backbone: 'backbone-browserify'

if process.env.NODE_ENV is 'development'
  bOpts.debug = true 
  bOpts.watch = true

if process.env.NODE_ENV is 'production'
  bOpts.filter = uglify

bundle = browserify bOpts
bundle.register '.jade', (body, fn) ->
  fn = jade.compile body, 
    compileDebug: false
    client: true
  
  return "module.exports = #{fn};"

bundle.prepend "window.VERSION = '#{version}';"

includes = [
  'jquery.min.js'
  'bootstrap.min.js'
]

for js in includes.reverse()
  bundle.prepend fs.readFileSync "./lib/client/vendor/#{js}"

bundle.prepend 'window.t0 = Date.now();'
bundle.append 'window.t1 = Date.now();'

bundle.addEntry './node_modules/jade/runtime.js'
bundle.addEntry './lib/client/entry.coffee'

module.exports = bundle