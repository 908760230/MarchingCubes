extends Node3D

var left_pressed = false;
var mouse_start
var origin_position

signal set_flag(pos:Vector3)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and left_pressed and not event.pressed:
			left_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if left_pressed:
		#var offset = get_viewport().get_mouse_position() - mouse_start
		
		var origin = get_viewport().get_camera_3d().project_ray_origin(get_viewport().get_mouse_position())
		var direction = get_viewport().get_camera_3d().project_ray_normal(get_viewport().get_mouse_position())
		var new_position = origin + direction * 3
		self.global_position = new_position
		emit_signal("set_flag",new_position)
		#self.position = origin_position + Vector3(offset.x,-offset.y,0) *delta


func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_pressed = true
			mouse_start = get_viewport().get_mouse_position()
			origin_position = self.position
		if left_pressed and not event.pressed:
			left_pressed = false
