express = require('express')
path = require('path')
http = require('http')
app = express()

app.set 'view engine', 'ejs'
app.set 'views', __dirname + '/views'

app.configure () ->
  app.set 'port', process.env.PORT || 3000
  app.use '/public', express.static(path.join(__dirname, 'public'))

app.get '/', (req, res) ->
  res.render 'index'

http.createServer(app).listen app.get 'port'
console.log 'Express server listening on port ' + app.get 'port'