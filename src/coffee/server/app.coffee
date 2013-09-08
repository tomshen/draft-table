express = require 'express'
path = require 'path'
http = require 'http'
_ = require 'underscore'

models = require './models'

app = express()

app.engine 'ejs', require('ejs-locals')
app.set 'view engine', 'ejs'
app.set 'views', __dirname + '/views'

app.configure () ->
  app.set 'port', process.env.PORT || 3000
  app.use '/public', express.static(path.join(__dirname, 'public'))
  app.use express.bodyParser({keepExtensions: true})

# User-facing views
app.get '/', (req, res) ->
  res.render 'index'

app.get '/:school', (req, res) ->
  models.School.get req.params.school, (err, school) ->
    res.render 'school', school

app.get '/:school/:plan', (req, res) ->
  models.School.get req.params.school, (err, school) ->
    models.Plan.get req.params.plan, (err, plan) ->
      res.render 'plan', { plan: plan, school: school }

app.get '/:school/:plan/proposal/new', (req, res) ->
  models.School.get req.params.school, (err, school) ->
    models.Plan.get req.params.plan, (err, plan) ->
      res.render 'proposal_new', { school: school, plan: plan }

# Views for POSTing
app.post '/school/:school/plan/new', (req, res) ->
  models.School.addPlan req.params.school, req.body, req.files, (id) -> res.send id

app.post '/plan/:plan/support', (req, res) ->
  models.Plan.addSupporter req.params.plan, req.body

app.post '/school/:school/plan/:plan/proposal/new', (req, res) ->
  models.Plan.addProposal req.params.plan, req.body, req.files, (id) -> 
    res.redirect "/#{req.params.school}" + '/#' + "#{req.params.plan}" 

app.post '/proposal/:proposal/support', (req, res) ->
  models.Proposal.addSupporter req.params.proposal, req.body

app.post '/proposal/:proposal/comment', (req, res) ->
  models.Proposal.addComment req.params.proposal, req.body

http.createServer(app).listen app.get 'port'
console.log 'Express server listening on port ' + app.get 'port'