window.drawModel = (sketchfabId) ->
  sketchfabURL = "https://sketchfab.com/oembed?url=https://sketchfab.com/show/#{sketchfabId}&maxheight=640&maxwidth=640"
  $container = $ "#model-#{sketchfabId}"
  $.getJSON sketchfabURL, (data) ->
    console.log data
    $container.html data.html