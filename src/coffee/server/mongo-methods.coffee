mongo = require 'mongoskin', log = console.log
# w:0 gets rid of the default write concern message, but may be unsafe for production since it doesn't force acknowledgement
# of writes to the DB
db = mongo.db('localhost:27017/testdb', {w: 0})

collection = db.collection('production');	

module.exports = collection