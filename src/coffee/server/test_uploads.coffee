request = require 'request'
formData = require 'form-data'
fs = require 'fs'

i = 0

# modelFile = req.files.model
# callback = (err, sketchfabId) -> ... 
uploadModel = (title, modelFile, callback) ->
  console.log "Title = #{title}, modelFile = #{modelFile}"
  i++
  callback(null, 'SketchFabId_'+i)

# imageFile = req.files.image
# callback = (err, fileName)
# image will be at /public/img/{fileName}
uploadImage = (imageFile, callback) ->
  console.log "imageFile = #{imageFile}"
  i++
  callback(null, 'imageFile_'+i)


module.exports = {uploadImage: uploadImage, uploadModel: uploadModel}