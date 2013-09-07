mongo = require 'mongoskin', _ = require 'underscore', log = console.log
# w:0 gets rid of the default write concern message, but may be unsafe for production since it doesn't force acknowledgement
# of writes to the DB
db = mongo.db('localhost:27017/test', {w: 0})

pluralize = (word) ->
  word + 's'

# Replacement for create; callback: (doc_id) ->
createDocWithParent = (type, parent_id, doc, collectionName, parentCollectionName, callback)->
  db.collection(collectionName).insert doc, (err, docs)->
    doc_ids = _.pluck docs, '_id'
    doc_id = doc_ids[0]
    addChildOfTypeById type, parentCollectionName, parent_id, doc_id, ()->
      callback doc_id

update = (collectionName, _id, update_object, callback)->
  db.collection(collectionName).updateById _id, update_object, callback

#replaces add ___by Id
addChildOfTypeById = (type, parentCollectionName, parent_id, doc_id, callback) ->
  db.collection(parentCollectionName).findById parent_id, (err, doc) ->
    fieldName = pluralize(type)
    child_array = doc[fieldName]
    child_array.push doc_id 
    update_obj = {}
    update_obj[fieldName] = child_array
    update parentCollectionName, parent_id, {$set: update_obj}, callback

School = {}
# callback : (_id ->) ->
School.create = (school, callback) ->
  if not (school.name? and school.email_domain?)
    throw new Error('School.create: name or email domain was undefined')
  db.collection('schools').insert school, (err, docs) ->
    callback docs[0]._id

School.update = (_id, update_object) ->
  db.collection('schools').updateById _id, {$set: update_object}

School.get = (school_id, callback) ->
  db.collection('schools').findById(school_id, callback)

# callback : (plan_id) -> ...
School.addPlan = (school_id, plan, callback) ->
  createDocWithParent 'plan', school_id, plan, 'plans', 'schools', callback


Plan = {}
#Callback: (proposal_id)-> ...
Plan.addProposal = (plan_id, proposal, callback) ->
  createDocWithParent 'proposal', plan_id, proposal, 'proposals', 'plans', callback

# callback: (plan) ->
Plan.get = (plan_id, callback)->
  db.collection('plans').findById plan_id, callback

Plan.update = (_id, update_object)->
  db.collection('plan').updateById _id, {$set: update_object}


Proposal = {}
#callback: (proposal) ->
Proposal.get = (proposal_id, callback)->
  db.collection('proposals').findById proposal_id, callback

Supporter = {}

Supporter.create = (parent_id, supporter, parentType, callback) ->
  parentObj = if parentType is 'plan' then Plan else if parentType is 'proposal' then Proposal else throw new Error('supporter: illegal parent type' + parentType)
  db.collection('supporters').insert supporter, (err, docs) ->
    supporters = _.pluck docs, '_id'
    parentObj.addSupporterById(parent_id, supporters[0])
    callback supporters[0]



Element = {}
Comment = {}

methods = 
  School: School
  Plan: Plan
  Element: Element
  Supporter: Supporter
  Proposal: Proposal
  Comment: Comment



module.exports = methods