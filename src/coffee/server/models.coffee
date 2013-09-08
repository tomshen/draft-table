mongo = require 'mongoskin'
_ = require 'underscore'
moment = require 'moment'
async = require 'async'
uploads = require './uploads.js'
log = console.log
# w:0 gets rid of the default write concern message, but may be unsafe for production since it doesn't force acknowledgement
# of writes to the DB
db = mongo.db('localhost:27017/test', {w: 0})

pluralize = (word) ->
  word + 's'

isNumber = (n) ->
  return !isNaN(parseFloat(n)) and isFinite(n);

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

updateByPush = (_id, listElt, listName, collectionName)->
  push_me = {}
  push_me[listName] = listElt
  update_object = { $push: push_me}
  db.collection(collectionName).updateById _id, update_object

School = {}
# callback : (_id ->) ->
School.create = (school, callback) ->
  if not (school.name? and school.email_domain?)
    throw new Error('School.create: name or email domain was undefined')
  db.collection('schools').insert school, (err, docs) ->
    callback docs[0]._id

School.update = (_id, update_object) ->
  db.collection('schools').updateById _id, {$set: update_object}

# callback (err, doc) -> ...
School.get = (school_id, callback) ->
  db.collection('schools').findById school_id, (err, doc) ->
    async.map doc.plans, (plan_id, callbackOnComplete) ->
      db.collection('plans').findById(plan_id, callbackOnComplete)
    ,(err, plans2) ->
      doc.plans = plans2
      callback err, doc

# callback : (plan_id) -> ...
School.addPlan = (school_id, plan, files, callback) ->
  createDocWithParent 'plan', school_id, plan, 'plans', 'schools', callback


makeElement = (elementName, content, _class)->
  elementIndex = elementName.replace(/\D/g,'')
  type = elementName.split('-')[1]
  ans =  {type: type, index: elementIndex, content: content}
  if _class
    ans._class = _class
  return ans

Plan = {}
#Callback: (proposal_id)-> ...
Plan.addProposal = (plan_id, proposal, files, callback) ->
  proposal_doc = {timestamp: moment().valueOf(), title: proposal.title, author: proposal.author, comments: [], supporters: []}
  elements = []
  _.chain(proposal).pairs().filter(
    (pair) -> return pair[0].indexOf('elt-text-') > -1
  ).each(
    (pair)->
      _class = pair[0].split('-')[2]
      if isNumber(_class)
        _class = undefined
      element = makeElement pair[0], pair[1], _class
      elements.push element
  )
  locationInputPairs = _.chain(proposal).pairs().filter(
    (pair) -> return pair[0].indexOf('elt-location-') > -1
  ).each((pair)->
    element = makeElement pair[0], pair[1].split(',')
    elements.push element
  )
  model_pairs = _.chain(files).pairs().filter((pair)->
    pair[0].indexOf('elt-model-') > -1
  ).value()

  image_pairs = _.chain(files).pairs().filter((pair)->
    pair[0].indexOf('elt-image-') > -1
  ).value()

  images_pairs = _.chain(files).pairs().filter((pair)->
    pair[0].indexOf('elt-images-') > -1
  ).value()

  async.parallel(
    [
      (done) ->
        async.each model_pairs, (item, callback)->
          #stub - make this model into an element and append that to elements
          uploads.uploadModel(proposal.title, item[1], (err, sketchfab_id)->
            if err
              throw err
            element = makeElement item[0], sketchfab_id
            elements.push element
            callback()
          )
        , done
      , (done) ->
        async.each image_pairs, (item, callback)->
          uploads.uploadImage(item[1], (err, fileName)->
            if err
              throw err
            element = makeElement item[0], fileName
            elements.push element
            callback()
          )
        , done
      , (done) ->
        async.each images_pairs, (item, callback)->
          #stub - make this images object into an element and append that to elements
          array_of_images = _.flatten(item[1])
          file_names = []
          async.each(array_of_images, (file, cb)->
            uploads.uploadImage(file, (err, fileName)->
              if err
                throw err
              file_names.push fileName
              cb()
            )
          , (err)->
            element = makeElement item[0], file_names
            elements.push element
            callback()
          )
        , done
    ], () ->
      proposal_doc.elements = elements
      createDocWithParent 'proposal', plan_id, proposal_doc, 'proposals', 'plans', callback
  )

# callback: (plan) ->
Plan.get = (plan_id, callback)->
  db.collection('plans').findById plan_id, callback

Plan.update = (_id, update_object)->
  db.collection('plans').updateById _id, {$set: update_object}

Plan.addSupporter = (plan_id, supporter)->
  updateByPush plan_id, supporter, 'supporters', 'plans'

Plan.addElement = (plan_id, element)->
  updateByPush plan_id, element, 'elements', 'plans'


Proposal = {}
#callback: (proposal) ->
Proposal.get = (proposal_id, callback)->
  db.collection('proposals').findById proposal_id, callback

Proposal.addSupporter = (proposal_id, supporter) ->
  updateByPush proposal_id, supporter, 'supporters', 'proposals'

Proposal.addElement = (proposal_id, element) ->
  updateByPush proposal_id, element, 'elements', 'proposals'

Proposal.addComment = (proposal_id, comment) ->
  comment.timestamp = moment().valueOf()
  updateByPush proposal_id, comment, 'comments', 'proposals'


methods =
  School: School
  Plan: Plan
  Proposal: Proposal




module.exports = methods