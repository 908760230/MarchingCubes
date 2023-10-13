extends Camera3D

var speed = 20
var move_forward = false
var move_left = false
var move_down = false
var move_right = false
var start_point
var is_rotate = false
var yaw = 0
var pitch = 0
var sensity = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_W:
			move_forward = true
		if event.keycode == KEY_S:
			move_down = true
		if event.keycode == KEY_A:
			move_left = true
		if event.keycode == KEY_D:
			move_right = true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		start_point = get_viewport().get_mouse_position()
		is_rotate = true
		if is_rotate and not event.pressed:
			is_rotate = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if move_forward:
		self.translate(Vector3(0,0,-1) * speed *delta)
	if move_left:
		self.translate(Vector3(-1,0,0) * speed *delta)
	if move_down:
		self.translate(Vector3(0,0,1) * speed *delta)
	if move_right:
		self.translate(Vector3(1,0,0) * speed *delta)
	
	if is_rotate:
		var mouse_delta = Input.get_last_mouse_velocity()
		yaw -= mouse_delta.x  * delta * sensity
		pitch -= mouse_delta.y  * delta * sensity
		rotation_degrees.y = yaw
		rotation_degrees.x = pitch
	move_forward = false
	move_left = false
	move_down = false
	move_right = false
