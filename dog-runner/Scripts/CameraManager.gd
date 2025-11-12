extends Node3D

# ============================================
# PROFESSIONAL CAMERA MANAGER
# Supports both Perspective and Isometric camera modes
# ============================================

enum CameraMode {
	PERSPECTIVE,  # Behind and above player (Temple Run style)
	ISOMETRIC     # Fixed isometric angle (Subway Surfer style)
}

@export var camera_mode: CameraMode = CameraMode.PERSPECTIVE
@export var camera: Camera3D

# Perspective camera settings
@export var perspective_height: float = 3.0  # Professional lower height
@export var perspective_back_distance: float = -9.0  # Slightly closer
@export var perspective_fov: float = 68.0  # Professional FOV
@export var perspective_look_ahead: float = 10.0  # Professional look ahead
@export var perspective_lerp_speed: float = 8.0

# Isometric camera settings
@export var isometric_height: float = 8.0  # Eye level height
@export var isometric_x_offset: float = -25.0  # Further left to avoid pillars
@export var isometric_z_distance: float = 0.0  # Aligned with player Z
@export var isometric_size: float = 16.0  # Zoomed out to compensate for distance
@export var isometric_look_ahead: float = 0.0  # No look ahead for side view
@export var isometric_lerp_speed_x: float = 8.0
@export var isometric_lerp_speed_z: float = 12.0

var target: Node3D
var ground_level: float = 1.5
var transition_progress: float = 0.0
var is_transitioning: bool = false
var start_camera_mode: CameraMode = CameraMode.PERSPECTIVE

func _ready():
	if not camera:
		camera = get_node_or_null("../Camera3D")
	
	setup_camera()

func setup_camera():
	if not camera:
		return
	
	match camera_mode:
		CameraMode.PERSPECTIVE:
			setup_perspective_camera()
		CameraMode.ISOMETRIC:
			setup_isometric_camera()

func setup_perspective_camera():
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = perspective_fov
	
	# Initial camera position
	camera.global_position = Vector3(
		0,
		perspective_height,
		perspective_back_distance
	)
	
	# Look ahead
	var look_target = Vector3(0, 2.0, perspective_look_ahead)
	camera.look_at(look_target, Vector3.UP)

func setup_isometric_camera():
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = isometric_size
	
	# Initial camera position - to the right side
	camera.global_position = Vector3(
		isometric_x_offset,
		isometric_height,
		isometric_z_distance
	)
	
	# Look at origin (player starting position)
	var look_target = Vector3(0, 2.0, 0)
	camera.look_at(look_target, Vector3.UP)

func set_transition_progress(progress: float):
	transition_progress = progress
	is_transitioning = progress < 1.0

func update_camera(delta: float, player: Node3D):
	if not camera or not player:
		return
	
	target = player
	
	if is_transitioning:
		update_transition_camera(delta)
	else:
		match camera_mode:
			CameraMode.PERSPECTIVE:
				update_perspective_camera(delta)
			CameraMode.ISOMETRIC:
				update_isometric_camera(delta)

func update_perspective_camera(delta: float):
	if not target:
		return
	
	# Maintain perspective projection
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	camera.fov = perspective_fov
	
	# Camera follows player smoothly
	var desired_camera_pos = Vector3(
		target.global_position.x,
		ground_level + perspective_height,
		target.global_position.z + perspective_back_distance
	)
	
	# Smooth camera movement
	camera.global_position = camera.global_position.lerp(desired_camera_pos, perspective_lerp_speed * delta)
	
	# Look ahead down the path
	var look_target = Vector3(
		target.global_position.x,
		target.global_position.y + 1.0,
		target.global_position.z + perspective_look_ahead
	)
	
	camera.look_at(look_target, Vector3.UP)

func update_isometric_camera(delta: float):
	if not target:
		return
	
	# Maintain orthographic projection
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = isometric_size
	
	# Camera positioned to the right side of player
	var desired_camera_pos = Vector3(
		target.global_position.x + isometric_x_offset,
		isometric_height,  # Fixed height
		target.global_position.z + isometric_z_distance
	)
	
	# Smooth X and Z movement (Y stays fixed)
	var current_pos = camera.global_position
	var new_pos = Vector3(
		current_pos.x + (desired_camera_pos.x - current_pos.x) * isometric_lerp_speed_x * delta,
		isometric_height,  # Always fixed
		current_pos.z + (desired_camera_pos.z - current_pos.z) * isometric_lerp_speed_z * delta
	)
	
	camera.global_position = new_pos
	
	# Look directly at the player (side view)
	var look_target = Vector3(
		target.global_position.x,
		target.global_position.y + 1.0,
		target.global_position.z
	)
	
	camera.look_at(look_target, Vector3.UP)

func update_transition_camera(delta: float):
	if not target:
		return
	
	# Smoothly interpolate between perspective and isometric
	var t = ease_in_out_cubic(transition_progress)
	
	# Perspective camera position
	var persp_pos = Vector3(
		target.global_position.x,
		ground_level + perspective_height,
		target.global_position.z + perspective_back_distance
	)
	
	# Isometric camera position
	var iso_pos = Vector3(
		target.global_position.x + isometric_x_offset,
		isometric_height,
		target.global_position.z + isometric_z_distance
	)
	
	# Lerp position
	camera.global_position = persp_pos.lerp(iso_pos, t)
	
	# Lerp FOV/Size (perspective to orthographic)
	if t < 0.5:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		camera.fov = lerp(perspective_fov, 90.0, t * 2.0)
	else:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = lerp(8.0, isometric_size, (t - 0.5) * 2.0)
	
	# Lerp look target
	var persp_look = Vector3(
		target.global_position.x,
		target.global_position.y + 1.0,
		target.global_position.z + perspective_look_ahead
	)
	var iso_look = Vector3(
		target.global_position.x,
		target.global_position.y + 1.0,
		target.global_position.z
	)
	var look_target = persp_look.lerp(iso_look, t)
	camera.look_at(look_target, Vector3.UP)

func ease_in_out_cubic(t: float) -> float:
	if t < 0.5:
		return 4.0 * t * t * t
	else:
		var f = (2.0 * t - 2.0)
		return 1.0 + 0.5 * f * f * f

func switch_camera_mode(new_mode: CameraMode):
	camera_mode = new_mode
	setup_camera()
