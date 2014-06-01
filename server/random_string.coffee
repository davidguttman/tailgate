chars = '0123456789 ABCDEFGHIJKLMNOPQRSTUVWXTZ abcdefghiklmnopqrstuvwxyz'

module.exports = (length) ->
  length = length or 64
    
  string = ''
  
  for i in [0...length]
    r = Math.floor (Math.random() * chars.length)
    string += chars.substring r, r + 1
  
  return string