// Generated by CoffeeScript 1.6.3
var formData, fs, request, uploadImage, uploadModel;

request = require('request');

formData = require('form-data');

fs = require('fs');

uploadModel = function(title, modelFile, callback) {
  var form;
  console.log(modelFile.path);
  form = new formData();
  form.append('title', title);
  form.append('fileModel', fs.createReadStream(modelFile.path));
  form.append('token', process.env.SKETCHFAB_API_KEY);
  form.append('private', 1);
  return form.getLength(function(err, length) {
    var r;
    if (err) {
      callback(err);
    }
    r = request.post('https://api.sketchfab.com/v1/models', {
      headers: {
        'content-length': length
      }
    }, function(err, response, body) {
      var fileName, id, newPath;
      body = JSON.parse(body);
      fileName = body["result"]["id"] + '.dae';
      id = body.result.id;
      console.log(id);
      newPath = __dirname + '/public/models/' + fileName;
      return fs.readFile(modelFile.path, function(err, data) {
        return fs.writeFile(newPath, data, function(err) {
          return callback(err, body.result.id);
        });
      });
    });
    return r._form = form;
  });
};

uploadImage = function(imageFile, callback) {
  return fs.readFile(imageFile.path, function(err, data) {
    var fileName, newPath;
    fileName = imageFile.path.split('/')[2] + '.' + imageFile.name.split('.')[1];
    newPath = __dirname + '/public/img/' + fileName;
    return fs.writeFile(newPath, data, function(err) {
      return callback(err, fileName);
    });
  });
};

module.exports = {
  uploadImage: uploadImage,
  uploadModel: uploadModel
};
