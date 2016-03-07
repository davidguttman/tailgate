var h = require('hyperscript')
var api = require('./api')

module.exports = function (el, path) {
  api.getPath(path, function (err, dir) {
    if (err) return console.error(err)

    el.innerHTML = ''
    el.appendChild(render({cwd: path, files: dir}))
  })
}

function render (state) {
  return (
    h('.directory',
      state.files.map(function (file) {
        if (file.isDirectory) return renderDirectory(file)
        return renderFile(file)
      })
    )
  )
}

function renderFile (file) {
  return h('.file',
    h('a', {href: file.url}, file.name)
  )
}

function renderDirectory (dir) {
  return h('.directory',
    h('a', {href: '#/' + dir.path}, dir.name)
  )
}
