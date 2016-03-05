process.env.NODE_ENV = 'test'
process.env.TAILGATE_DIR = __dirname + '/fixtures'

require('coffee-script/register')

require('./server')

