// Generated by CoffeeScript 1.6.3
var Plan, Proposal, School, addChildOfTypeById, async, createDocWithParent, db, isNumber, log, makeElement, methods, migrations, moment, mongo, pluralize, update, updateByPush, uploads, _;

mongo = require('mongoskin');

_ = require('underscore');

moment = require('moment');

async = require('async');

uploads = require('./uploads.js');

log = console.log;

db = mongo.db(process.env.CUSTOMCONNSTR_MONGOLAB_URI, {
  w: 0
});

pluralize = function(word) {
  return word + 's';
};

isNumber = function(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
};

createDocWithParent = function(type, parent_id, doc, collectionName, parentCollectionName, callback) {
  return db.collection(collectionName).insert(doc, function(err, docs) {
    var doc_id, doc_ids;
    doc_ids = _.pluck(docs, '_id');
    doc_id = doc_ids[0];
    return addChildOfTypeById(type, parentCollectionName, parent_id, doc_id, function() {
      return callback(doc_id);
    });
  });
};

update = function(collectionName, _id, update_object, callback) {
  return db.collection(collectionName).updateById(_id, update_object, callback);
};

addChildOfTypeById = function(type, parentCollectionName, parent_id, doc_id, callback) {
  return db.collection(parentCollectionName).findById(parent_id, function(err, doc) {
    var child_array, fieldName, update_obj;
    fieldName = pluralize(type);
    child_array = doc[fieldName];
    child_array.push(doc_id);
    update_obj = {};
    update_obj[fieldName] = child_array;
    return update(parentCollectionName, parent_id, {
      $set: update_obj
    }, callback);
  });
};

updateByPush = function(_id, listElt, listName, collectionName) {
  var push_me, update_object;
  push_me = {};
  push_me[listName] = listElt;
  update_object = {
    $push: push_me
  };
  return db.collection(collectionName).updateById(_id, update_object);
};

School = {};

School.create = function(school, callback) {
  if (!((school.name != null) && (school.email_domain != null))) {
    throw new Error('School.create: name or email domain was undefined');
  }
  return db.collection('schools').insert(school, function(err, docs) {
    return callback(docs[0]._id);
  });
};

School.update = function(_id, update_object) {
  return db.collection('schools').updateById(_id, {
    $set: update_object
  });
};

School.get = function(school_id, callback) {
  return db.collection('schools').findById(school_id, function(err, doc) {
    var e;
    try {
      return async.map(doc.plans, function(plan_id, callbackOnComplete) {
        return db.collection('plans').findById(plan_id, callbackOnComplete);
      }, function(err, plans2) {
        doc.plans = plans2;
        return callback(void 0, doc);
      });
    } catch (_error) {
      e = _error;
      console.log("There was an error!");
      return console.log(e);
    }
  });
};

School.addPlan = function(school_id, plan, files, callback) {
  return createDocWithParent('plan', school_id, plan, 'plans', 'schools', callback);
};

makeElement = function(elementName, content, _class) {
  var ans, elementIndex, type;
  elementIndex = elementName.replace(/\D/g, '');
  type = elementName.split('-')[1];
  ans = {
    type: type,
    index: elementIndex,
    content: content
  };
  if (_class) {
    ans._class = _class;
  }
  return ans;
};

Plan = {};

Plan.addProposal = function(plan_id, proposal, files, callback) {
  var elements, image_pairs, images_pairs, locationInputPairs, model_pairs, proposal_doc;
  proposal_doc = {
    timestamp: moment().valueOf(),
    title: proposal.title,
    author: proposal.author,
    comments: [],
    supporters: []
  };
  elements = [];
  _.chain(proposal).pairs().filter(function(pair) {
    return pair[0].indexOf('elt-text-') > -1;
  }).each(function(pair) {
    var element, _class;
    _class = pair[0].split('-')[2];
    if (isNumber(_class)) {
      _class = void 0;
    }
    element = makeElement(pair[0], pair[1], _class);
    return elements.push(element);
  });
  locationInputPairs = _.chain(proposal).pairs().filter(function(pair) {
    return pair[0].indexOf('elt-location-') > -1;
  }).each(function(pair) {
    var element;
    element = makeElement(pair[0], pair[1].split(','));
    return elements.push(element);
  });
  model_pairs = _.chain(files).pairs().filter(function(pair) {
    return pair[0].indexOf('elt-model-') > -1;
  }).value();
  image_pairs = _.chain(files).pairs().filter(function(pair) {
    return pair[0].indexOf('elt-image-') > -1;
  }).value();
  images_pairs = _.chain(files).pairs().filter(function(pair) {
    return pair[0].indexOf('elt-images-') > -1;
  }).value();
  return async.parallel([
    function(done) {
      return async.each(model_pairs, function(item, callback) {
        return uploads.uploadModel(proposal.title, item[1], function(err, sketchfab_id) {
          var element;
          if (err) {
            throw err;
          }
          element = makeElement(item[0], sketchfab_id);
          elements.push(element);
          return callback();
        });
      }, done);
    }, function(done) {
      return async.each(image_pairs, function(item, callback) {
        return uploads.uploadImage(item[1], function(err, fileName) {
          var element;
          if (err) {
            throw err;
          }
          element = makeElement(item[0], fileName);
          elements.push(element);
          return callback();
        });
      }, done);
    }, function(done) {
      return async.each(images_pairs, function(item, callback) {
        var array_of_images, file_names;
        array_of_images = _.flatten(item[1]);
        file_names = [];
        return async.each(array_of_images, function(file, cb) {
          return uploads.uploadImage(file, function(err, fileName) {
            if (err) {
              throw err;
            }
            file_names.push(fileName);
            return cb();
          });
        }, function(err) {
          var element;
          element = makeElement(item[0], file_names);
          elements.push(element);
          return callback();
        });
      }, done);
    }
  ], function() {
    proposal_doc.elements = elements;
    return createDocWithParent('proposal', plan_id, proposal_doc, 'proposals', 'plans', callback);
  });
};

Plan.get = function(plan_id, callback) {
  return db.collection('plans').findById(plan_id, function(err, doc) {
    var e;
    try {
      return async.map(doc.proposals, function(proposal_id, callbackOnComplete) {
        return db.collection('proposals').findById(proposal_id, callbackOnComplete);
      }, function(err, proposals2) {
        doc.proposals = proposals2;
        return callback(void 0, doc);
      });
    } catch (_error) {
      e = _error;
      console.log("There was an error!");
      return console.log(e);
    }
  });
};

Plan.update = function(_id, update_object) {
  return db.collection('plans').updateById(_id, {
    $set: update_object
  });
};

Plan.addSupporter = function(plan_id, supporter) {
  return updateByPush(plan_id, supporter, 'supporters', 'plans');
};

Plan.addElement = function(plan_id, element) {
  return updateByPush(plan_id, element, 'elements', 'plans');
};

Proposal = {};

Proposal.get = function(proposal_id, callback) {
  return db.collection('proposals').findById(proposal_id, callback);
};

Proposal.addSupporter = function(proposal_id, supporter) {
  return updateByPush(proposal_id, supporter, 'supporters', 'proposals');
};

Proposal.addElement = function(proposal_id, element) {
  return updateByPush(proposal_id, element, 'elements', 'proposals');
};

Proposal.addComment = function(proposal_id, comment) {
  comment.timestamp = moment().valueOf();
  return updateByPush(proposal_id, comment, 'comments', 'proposals');
};

methods = {
  School: School,
  Plan: Plan,
  Proposal: Proposal
};

migrations = require('./migrations.js');

console.log("i am being deployed on azure");

School.create(migrations.school, function(_id) {
  console.log("School _id is " + _id);
  return School.addPlan(_id, migrations.plan1, {}, function(plan_id) {
    console.log("Plan _id is " + plan_id);
    return School.addPlan(_id, migrations.plan2, {}, function(plan2_id) {
      return console.log("Plan 2 _id is " + plan2_id);
    });
  });
});

module.exports = methods;
