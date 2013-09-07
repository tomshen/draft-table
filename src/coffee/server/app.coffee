express = require 'express'
path = require 'path'
http = require 'http'
_ = require 'underscore'

models = require './models'

models.School.create {name: 'name', email_domain: 'domain', plans: []}, (_id) ->
    models.School.addPlan _id, {title: 'title', image_thumbnail: 'thumb', supporters: [], proposals: [], element: []}, (plan_id)->
      models.Plan.addProposal plan_id, {this_is: 'a proposal'}, (prop_id)->
        console.log "proposal ID is #{prop_id}"
    models.School.update _id, {name: 'Penn', email_domain: 'upenn.edu'}

app = express()

app.set 'view engine', 'ejs'
app.set 'views', __dirname + '/views'

app.configure () ->
  app.set 'port', process.env.PORT || 3000
  app.use '/public', express.static(path.join(__dirname, 'public'))

# User-facing views
app.get '/', (req, res) ->
  res.render 'index'

app.get '/:school', (req, res) ->
  models.School.get req.params.school, (err, school) ->
    res.render 'school', school

app.get '/:school/:plan', (req, res) ->
  models.Plan.get req.params.plan, (err, plan) ->
    res.render 'plan', plan

app.get '/:school/:plan/proposal', (req, res) ->
  models.School.get req.params.school, (err, school) ->
    models.Plan.get req.params.plan, (err, plan) ->
      res.render 'new_proposal', { school: school, plan: plan }

# Views for POSTing
app.post '/school/:school/plan/new', (req, res) ->
  models.School.addPlan req.params.school, req.body, (id) -> res.send id

app.post '/plan/:plan/support', (req, res) ->
  models.Plan.addSupporter req.params.plan, req.body

app.post '/plan/:plan/proposal/new', (req, res) ->
  models.Plan.addProposal req.params.plan, req.body, (id) -> res.send id

app.post '/proposal/:proposal/support', (req, res) ->
  models.Proposal.addSupporter req.params.proposal, req.body

app.post '/proposal/:proposal/comment', (req, res) ->
  models.Proposal.addComment req.params.proposal, req.body

http.createServer(app).listen app.get 'port'
console.log 'Express server listening on port ' + app.get 'port'