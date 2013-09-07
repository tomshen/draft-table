# set the scene size
WIDTH = 400
HEIGHT = 300
# set some camera attributes
VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

# get the DOM element to attach to
# - assume we've got jQuery to hand
$container = $ '#model-container'

# create a WebGL renderer, camera
# and a scene
renderer = new THREE.WebGLRenderer()
camera = new THREE.PerspectiveCamera VIEW_ANGLE, ASPECT, NEAR, FAR

scene = new THREE.Scene()

# add the camera to the scene
scene.add camera

# the camera starts at 0,0,0
# so pull it back
camera.position.z = 300

# start the renderer
renderer.setSize WIDTH, HEIGHT

# attach the render-supplied DOM element
$container.append renderer.domElement

loader = new THREE.ColladaLoader()
loader.load '/public/models/Haus.dae', (result) ->
  scene.add result.scene

renderer.render scene, camera