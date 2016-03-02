var tape = require('tape')
var servertest = require('servertest')

var createServer = require('../server')

tape('it should get root dir listing', function (t) {
  servertest(
    createServer({authData: {email: 'music@fan.com'}}),
    '/api/get?path=/',
    { encoding: 'json' },
    function (err, res) {
      t.ifError(err, 'should not error')
      var files = res.body

      t.equal(files[0].name, 'somedir', 'name should match')
      t.equal(files[0].isDirectory, true, 'isDirectory should match')
      t.equal(files[0].size, 102, 'size should match')
      t.equal(files[0].ext, '', 'ext should match')

      t.equal(files[1].name, 'text.txt', 'name should match')
      t.equal(files[1].isDirectory, false, 'isDirectory should match')
      t.equal(files[1].size, 19, 'size should match')
      t.equal(files[1].ext, 'txt', 'ext should match')

      t.end()
    }
  )
})

tape('it should get a sub directory listing', function (t) {
  servertest(
    createServer({authData: {email: 'music@fan.com'}}),
    '/api/get?path=/somedir',
    { encoding: 'json' },
    function (err, res) {
      t.ifError(err, 'should not error')
      var files = res.body

      t.equal(files[0].name, 'another-text.txt', 'name should match')
      t.equal(files[0].isDirectory, false, 'isDirectory should match')
      t.equal(files[0].size, 16, 'size should match')
      t.equal(files[0].ext, 'txt', 'ext should match')

      t.end()
    }
  )
})

tape('it should get a file', function (t) {
  servertest(
    createServer({authData: {email: 'music@fan.com'}}),
    '/api/get?path=/somedir/another-text.txt',
    { encoding: 'utf8' },
    function (err, res) {
      t.ifError(err, 'should not error')

      var content = res.body
      t.equal(content, 'some other file\n', 'file content should match')

      t.end()
    }
  )
})
