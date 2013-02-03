fs = require 'fs'
colors = require 'colors'
path = require 'path'
mkdirp = require 'mkdirp'
getRandomString = require './random_string'

home = process.env.HOME || process.env.USERPROFILE
configFile = home + '/.config/tailgate/config.json'

mkdirp.sync (path.dirname configFile), 0o0700

makeNewConfig = ->
  console.log ("[TAILGATE] No config found.").yellow
  console.log ("[TAILGATE] Creating new config file at #{configFile}").yellow
  console.log ("[TAILGATE] Tailgate will be in 'open mode' until first login.").yellow


  config =
    secret: getRandomString()
    users: []

  fs.writeFileSync configFile, (JSON.stringify config, null, '  ')

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

module.exports = config

