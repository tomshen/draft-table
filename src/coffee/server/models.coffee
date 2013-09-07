mongo = require 'mongoskin', _ = require 'underscore', log = console.log
# w:0 gets rid of the default write concern message, but may be unsafe for production since it doesn't force acknowledgement
# of writes to the DB
db = mongo.db('localhost:27017/test', {w: 0})

School = {}
# callback : (_id ->) ->
School.create = (school, callback) ->
  if not (school.name? and school.email_domain?)
    throw new Error('School.create: name or email domain was undefined')
  db.collection('schools').insert school, (err, docs) ->
    callback docs[0]._id

School.update = (_id, update_object) ->
  {name, email_domain, plans} = update_object
  if name?
    db.collection('schools').updateById _id, {$set: {name: name}}
  if email_domain?
    db.collection('schools').updateById _id, {$set: {email_domain: email_domain}}
  if plans?
    db.collection('schools').updateById _id, {$set: {plans: plans}}

School.get = (school_id, callback) ->
  db.collection('schools').findById(school_id, callback)

# callback : (_id) ->
School.addPlan = (_id, object, callback) ->
  Plan.create(_id, object, callback)

School.addPlanById = (school_id, plan_id) ->
  db.collection('schools').findOne school_id, (err, doc) ->
    plans = doc.plans
    plans.push plan_id
    School.update school_id, {plans: plans}

School.removePlanById = (school_id, plan_id) ->
  db.collection('schools').findById school_id, (err, doc) ->
    console.log doc.plans
    mod_plans = _.reject doc.plans, (id) -> 
      console.log 'value'
      console.log id.toString() == plan_id.toString()
      return id.toString() == plan_id.toString()
    console.log mod_plans
    School.update school_id, {plans: mod_plans}

Plan = {}
#Callback: (plan_id) -> ...
Plan.create = (school_id, plan, callback) ->
  db.collection('plans').insert plan, (err, docs) ->
    plans = _.pluck docs, '_id'
    School.addPlanById(school_id, plans[0])
    callback plans[0]

Element = {}
Supporter = {}
Proposal = {}
Comment = {}

methods = 
  School: School
  Plan: Plan
  Element: Element
  Supporter: Supporter
  Proposal: Proposal
  Comment: Comment



module.exports = methods