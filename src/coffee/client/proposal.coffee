window.addTextInput = () ->
  container = $('<div>').attr('class', 'text-input-container')
  node = $('<textarea>').attr('name', _.uniqueId('elt-text-'))
    .attr('class', 'text-input')
  container.append node
  $('#proposal-elements').append container

window.addImageInput = () ->
  container = $('<div>').attr('class', 'image-input-container')
  node = $('<input>').attr('type', 'file').attr('name', _.uniqueId('elt-image-'))
    .attr('class', 'image-input').attr('accept', 'image/*')
  container.append node
  $('#proposal-elements').append container

# DO NOT USE, POSSIBLY NOT SUPPORTED EXPRESS
window.addImageStripInput = () ->
  container = $('<div>').attr('class', 'image-strip-input-container')
  node = $('<input>').attr('type', 'file').attr('name', _.uniqueId('elt-images-'))
    .attr('class', 'image-strip-input').attr('accept', 'image/*')
    .attr('multiple', true)
  container.append node
  $('#proposal-elements').append container

window.addModelInput = () ->
  container = $('<div>').attr('class', 'model-input-container')
  node = $('<input>').attr('type', 'file').attr('name', _.uniqueId('elt-model-'))
    .attr('class', 'model-input').attr('accept', 'model/*')
  container.append node
  $('#proposal-elements').append container

window.addLocationInput = () ->
  container = $('<div>').attr('class', 'location-input-container')
  node = $('<input>').attr('type', 'text').attr('name', _.uniqueId('elt-location-'))
    .attr('class', 'location-input')
  container.append node
  $('#proposal-elements').append container