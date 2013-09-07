// Generated by CoffeeScript 1.6.3
(function() {
  var app, express, http, path;

  express = require('express');

  path = require('path');

  http = require('http');

  app = express();

  app.set('view engine', 'ejs');

  app.set('views', __dirname + '/views');

  app.configure(function() {
    app.set('port', process.env.PORT || 3000);
    return app.use('/public', express["static"](path.join(__dirname, 'public')));
  });

  app.get('/', function(req, res) {
    return res.render('index');
  });

  http.createServer(app).listen(app.get('port'));

  console.log('Express server listening on port ' + app.get('port'));

}).call(this);
