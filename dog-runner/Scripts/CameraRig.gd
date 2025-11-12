extends Camera3D

@export var target_path: NodePath
@export var base_offset: Vector3 = Vector3(-12, 6, 0)
@export var look_ahead_factor: float = 0.6
@export var min_look_ahead: float = 4.0
@export var max_look_ahead: float = 12.0
@export var follow_lerp_speed: float = 6.0
@export var orthographic_size: float = 14.0

var target: Node3D

func _ready():
	# Configure orthographic view for clean, professional 2.5D framing
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = orthographic_size
	# Resolve target lazily in case scene order changes
	target = get_node_or_null(target_path) as Node3D

func apply_follow(delta: float, speed: float):
	# Public method that external controllers can call each frame 
	if target == null:
		target = get_node_or_null(target_path) as Node3D
		if target == null:
			return
	
	var look_ahead: float = float(clamp(speed * look_ahead_factor, min_look_ahead, max_look_ahead))
	var desired_pos: Vector3 = target.global_position + base_offset
	global_position = global_position.lerp(desired_pos, follow_lerp_speed * delta)

	var look_target: Vector3 = target.global_position + Vector3(0, 2.0, look_ahead)
	look_at(look_target, Vector3.UP)
