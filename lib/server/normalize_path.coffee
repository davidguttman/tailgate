path = require 'path'
normalize = path.normalize
join = path.join
root = process.argv[2] or process.cwd()

module.exports = (relpath) ->
  normalize(join(root, relpath))

module.exports.root = root