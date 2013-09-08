request = require 'request'
formData = require 'form-data'
fs = require 'fs'

# modelFile = req.files.model
# callback = (err, sketchfabId) -> ... 
uploadModel = (title, modelFile, callback) ->
  console.log modelFile.path
  form = new formData()
  form.append 'title', title
  form.append 'fileModel', fs.createReadStream modelFile.path
  form.append 'token', process.env.SKETCHFAB_API_KEY
  form.append 'private', 1

  form.getLength (err, length) ->
    callback err if err

    r = request.post 'https://api.sketchfab.com/v1/models',
      { headers: {'content-length': length} },
      (err, response, body) ->
        body = JSON.parse body
        fileName = body["result"]["id"] + '.dae'
        id = body.result.id
        console.log id
        newPath = __dirname + '/public/models/' + fileName
        fs.readFile modelFile.path, (err, data)->
          fs.writeFile newPath, data, (err)->
            callback err, body.result.id
    r._form = form

# imageFile = req.files.image
# callback = (err, fileName)
# image will be at /public/img/{fileName}
uploadImage = (imageFile, callback) ->
  fs.readFile imageFile.path, (err, data) ->
    fileName = imageFile.path.split('/')[2] + '.' + imageFile.name.split('.')[1]
    newPath = __dirname + '/public/img/' + fileName
    fs.writeFile newPath, data, (err) ->
      callback err, fileName


module.exports = {uploadImage: uploadImage, uploadModel: uploadModel}