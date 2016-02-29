fs = require 'fs'
colors = require 'colors'
path = require 'path'
mkdirp = require 'mkdirp'

home = process.env.HOME || process.env.USERPROFILE
configFile = home + '/.config/tailgate/config.json'

mkdirp.sync (path.dirname configFile), 0o0700

save = (data) ->
  fs.writeFileSync configFile, (JSON.stringify data, null, '  ')

makeNewConfig = ->
  console.log ("[TAILGATE] No config found.").yellow
  console.log ("[TAILGATE] Creating new config file at #{configFile}").yellow
  console.log ("[TAILGATE] Tailgate will be in 'open mode' until first login.").yellow

  config =
    users: []

  save config
  return config

try
  config = require configFile
catch e
  errorType = e.code or e.type
  if errorType is 'MODULE_NOT_FOUND'
    config = makeNewConfig()
  else if errorType is 'unexpected_token'
    console.error ("[TAILGATE] Invalid JSON in #{configFile}").red
    console.error ("[TAILGATE] Please fix or remove file.").yellow
    throw e
  else
    throw e

module.exports =
  data: config
  save: ->
    save config

