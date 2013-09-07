// Generated by CoffeeScript 1.6.3
(function() {
  var app, express, http, models, path, _;

  express = require('express');

  path = require('path');

  http = require('http');

  _ = require('underscore');

  models = require('./models');

  models.School.create({
    name: 'name',
    email_domain: 'domain',
    plans: []
  }, function(_id) {
    models.School.addPlan(_id, {
      title: 'title',
      image_thumbnail: 'thumb',
      supporters: [],
      proposals: [],
      elements: []
    }, function(plan_id) {
      models.Plan.addProposal(plan_id, {
        this_is: 'a proposal'
      }, function(prop_id) {
        return console.log("proposal ID is " + prop_id);
      });
      return models.Plan.addSupporter(plan_id, {
        name: "Sammy Supporter",
        email: "sam@supportmemaybe.net"
      });
    });
    return models.School.update(_id, {
      name: 'Penn',
      email_domain: 'upenn.edu'
    });
  });

  app = express();

  app.engine('ejs', require('ejs-locals'));

  app.set('view engine', 'ejs');

  app.set('views', __dirname + '/views');

  app.configure(function() {
    app.set('port', process.env.PORT || 3000);
    return app.use('/public', express["static"](path.join(__dirname, 'public')));
  });

  app.get('/', function(req, res) {
    return res.render('index');
  });

  app.get('/:school', function(req, res) {
    return models.School.get(req.params.school, function(err, school) {
      return res.render('school', school);
    });
  });

  app.get('/:school/:plan', function(req, res) {
    return models.Plan.get(req.params.plan, function(err, plan) {
      return res.render('plan', plan);
    });
  });

  app.get('/:school/:plan/proposal', function(req, res) {
    return models.School.get(req.params.school, function(err, school) {
      return models.Plan.get(req.params.plan, function(err, plan) {
        return res.render('new_proposal', {
          school: school,
          plan: plan
        });
      });
    });
  });

  app.post('/school/:school/plan/new', function(req, res) {
    return models.School.addPlan(req.params.school, req.body, req.files, function(id) {
      return res.send(id);
    });
  });

  app.post('/plan/:plan/support', function(req, res) {
    return models.Plan.addSupporter(req.params.plan, req.body);
  });

  app.post('/plan/:plan/proposal/new', function(req, res) {
    return models.Plan.addProposal(req.params.plan, req.body, req.files, function(id) {
      return res.send(id);
    });
  });

  app.post('/proposal/:proposal/support', function(req, res) {
    return models.Proposal.addSupporter(req.params.proposal, req.body);
  });

  app.post('/proposal/:proposal/comment', function(req, res) {
    return models.Proposal.addComment(req.params.proposal, req.body);
  });

  http.createServer(app).listen(app.get('port'));

  console.log('Express server listening on port ' + app.get('port'));

}).call(this);
