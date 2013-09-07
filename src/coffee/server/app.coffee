express = require('express')
path = require('path')
http = require('http')
app = express()
models = require './models.js'

models.School.create {name: 'name', email_domain: 'domain', plans: []}, (_id) ->
    models.School.update _id, {name: 'Penn'}
    models.School.addPlan _id, {title: 'title', image_thumbnail: 'thumbnail', supporters: [], proposals: [], elements: []}, (plan_id)->
        console.log plan_id
    models.School.get _id, (err, doc) ->
        console.log doc

    models.School.removePlanById '522ac1733c3dc5b41b000001', '522ac1733c3dc5b41b000002'


app.set 'view engine', 'ejs'
app.set 'views', __dirname + '/views'

app.configure () ->
  app.set 'port', process.env.PORT || 3000
  app.use '/public', express.static(path.join(__dirname, 'public'))

app.get '/', (req, res) ->
  res.render 'index'

http.createServer(app).listen app.get 'port'
console.log 'Express server listening on port ' + app.get 'port'