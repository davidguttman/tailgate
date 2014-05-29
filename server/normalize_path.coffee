path = require 'path'
normalize = path.normalize
join = path.join
root = process.env.TAILGATE_DIR or process.argv[2] or process.cwd()

module.exports = (relpath) ->
  normalize(join(root, relpath))

module.exports.root = root
