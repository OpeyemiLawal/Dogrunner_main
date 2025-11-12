extends CharacterBody3D

# Lane system (3 lanes like Temple Run/Subway Surfer)
const LANE_DISTANCE: float = 2.15
const LANE_CHANGE_SPEED: float = 15.0

enum Lane { LEFT = -1, CENTER = 0, RIGHT = 1 }
var current_lane: Lane = Lane.CENTER
var target_x: float = 0.0

# Movement
const JUMP_VELOCITY: float = 12.0
const GRAVITY: float = 30.0
const SLIDE_DURATION: float = 0.5

var is_jumping: bool = false
var is_sliding: bool = false
var slide_timer: float = 0.0

# Forward movement (controlled by GameManager)
var forward_speed: float = 0.0

# Touch/Swipe controls
var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: float = 0.0
var is_swiping: bool = false
const SWIPE_THRESHOLD: float = 50.0  # Minimum distance for swipe
const SWIPE_TIMEOUT: float = 0.5  # Max time for swipe (seconds)
const TAP_THRESHOLD: float = 30.0  # Max distance for tap
const TAP_TIMEOUT: float = 0.3  # Max time for tap

# Touch sensitivity settings
var swipe_sensitivity: float = 1.0  # Adjustable sensitivity (0.5 - 2.0)
var diagonal_threshold: float = 0.6  # How diagonal before rejecting (0-1)

# Haptic feedback
var haptic_enabled: bool = true

func _ready():
	# Start in center lane
	position.x = 0.0
	# Ensure player is at correct height (capsule bottom at Y=0.0)
	# Capsule: radius=0.5, height=2.0, so total height=3.0
	# Bottom of capsule = position.y - (height/2 + radius) = position.y - 1.5
	# For bottom to be at Y=0.0, position.y must be 1.5
	if position.y < 1.5:
		position.y = 1.5

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			touch_start_time = Time.get_ticks_msec() / 1000.0
			is_swiping = true
		else:
			if is_swiping:
				var touch_end_pos = event.position
				var touch_duration = (Time.get_ticks_msec() / 1000.0) - touch_start_time
				detect_swipe_or_tap(touch_start_pos, touch_end_pos, touch_duration)
				is_swiping = false

func _physics_process(delta):
	# Get forward speed from game manager
	var game_manager = get_parent()
	if game_manager and game_manager.has_method("_process"):
		forward_speed = game_manager.game_speed
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# Handle sliding
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			end_slide()
	
	# Lane movement
	target_x = current_lane * LANE_DISTANCE
	position.x = lerp(position.x, target_x, LANE_CHANGE_SPEED * delta)
	
	# Forward movement
	velocity.z = forward_speed
	$AnimationPlayer.play("Dog|Run")
	velocity.x = 0  # Lane changes handled by position.x
	
	# Move player
	move_and_slide()
	
	# Check for obstacle collisions
	check_obstacle_collision()
	
	# Check for pit collisions (one-time damage per pit)
	check_pit_collision()
	
	# Check for box collisions (one-time damage per box)
	check_box_collision()
	
	# Check for colored obstacle collisions (one-time damage per colored obstacle)
	check_colored_obstacle_collision()
	
	# Handle input
	handle_input()

func handle_input():
	# Keyboard controls for testing
	if Input.is_action_just_pressed("ui_right"):
		move_left()
	if Input.is_action_just_pressed("ui_left"):
		move_right()
	if Input.is_action_just_pressed("ui_up"):
		jump()
	if Input.is_action_just_pressed("ui_down"):
		slide()

func detect_swipe_or_tap(start: Vector2, end: Vector2, duration: float):
	var swipe = end - start
	var distance = swipe.length()
	
	# Apply sensitivity multiplier
	var adjusted_threshold = SWIPE_THRESHOLD / swipe_sensitivity
	
	# Check if it's a tap (short duration, small distance)
	if distance < TAP_THRESHOLD and duration < TAP_TIMEOUT:
		# Tap detected - could be used for power-ups later
		on_tap()
		return
	
	# Check if swipe is strong enough
	if distance < adjusted_threshold:
		return
	
	# Check if swipe took too long
	if duration > SWIPE_TIMEOUT:
		return
	
	# Normalize swipe vector
	var swipe_normalized = swipe.normalized()
	
	# Determine primary direction (horizontal or vertical)
	var horizontal_strength = abs(swipe_normalized.x)
	var vertical_strength = abs(swipe_normalized.y)
	
	# Reject diagonal swipes that are too ambiguous
	var direction_clarity = abs(horizontal_strength - vertical_strength)
	if direction_clarity < diagonal_threshold:
		return  # Too diagonal, reject
	
	# Determine swipe direction
	if vertical_strength > horizontal_strength:
		# Vertical swipe
		if swipe_normalized.y < 0:
			# Swipe up
			jump()
			trigger_haptic_feedback()
		else:
			# Swipe down
			slide()
			trigger_haptic_feedback()
	else:
		# Horizontal swipe
		if swipe_normalized.x > 0:
			# Swipe right
			move_right()
			trigger_haptic_feedback()
		else:
			# Swipe left
			move_left()
			trigger_haptic_feedback()

func on_tap():
	# Tap action - reserved for power-up activation
	pass

func move_left():
	if current_lane > Lane.LEFT:
		current_lane -= 1

func move_right():
	if current_lane < Lane.RIGHT:
		current_lane += 1

func jump():
	if is_on_floor() and not is_sliding:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		$AnimationPlayer.play("Dog|Jump")

func slide():
	if not is_sliding and is_on_floor():
		is_sliding = true
		slide_timer = SLIDE_DURATION
		# TODO: Change collision shape for sliding

func end_slide():
	is_sliding = false
	# TODO: Restore collision shape

func _on_obstacle_hit():
	# Called when player hits an obstacle
	var game_manager = get_parent()
	if game_manager and game_manager.has_method("take_damage"):
		game_manager.take_damage(1)  # Take 1 damage per obstacle hit

func trigger_haptic_feedback():
	# Trigger haptic feedback on mobile devices
	if haptic_enabled:
		if OS.has_feature("mobile"):
			# Vibrate for 50ms
			Input.vibrate_handheld(50)

func set_swipe_sensitivity(sensitivity: float):
	# Adjust swipe sensitivity (0.5 = less sensitive, 2.0 = more sensitive)
	swipe_sensitivity = clamp(sensitivity, 0.5, 2.0)

func set_haptic_enabled(enabled: bool):
	haptic_enabled = enabled

func check_pit_fall():
	# Check if player fell into a pit (below floor level)
	if position.y < -1.0:  # Player fell below floor level
		_on_obstacle_hit()  # Treat pit fall as obstacle hit
		# Reset player position to avoid multiple damage
		position.y = 1.5

func check_obstacle_collision():
	# Check if player collided with any obstacles (excluding boxes which use area detection)
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("obstacles") and not collider.is_in_group("box_obstacles"):
			# Hit an obstacle (but not boxes, which use area detection)
			print("Hit obstacle: ", collider.name)
			_on_obstacle_hit()
			break

func check_pit_collision():
	# Check for pit collisions using area detection (not physics collision)
	if not is_inside_tree():
		return  # Not in scene tree yet
	
	var pit_areas = get_tree().get_nodes_in_group("pits")
	for pit_area in pit_areas:
		if pit_area is Area3D:
			var overlapping_bodies = pit_area.get_overlapping_bodies()
			for body in overlapping_bodies:
				if body == self and not pit_area.get_meta("damage_dealt", false):
					# Player entered pit area and hasn't taken damage from this pit yet
					print("Fell into pit: ", pit_area.get_meta("pit_id", "unknown"))
					pit_area.set_meta("damage_dealt", true)  # Mark as damaged
					_on_obstacle_hit()
					break

func check_box_collision():
	# Check for box collisions using area detection (not physics collision)
	if not is_inside_tree():
		return  # Not in scene tree yet
	
	var box_areas = get_tree().get_nodes_in_group("box_obstacles")
	for box_area in box_areas:
		if box_area is Area3D:
			var overlapping_bodies = box_area.get_overlapping_bodies()
			for body in overlapping_bodies:
				if body == self and not box_area.get_meta("damage_dealt", false):
					# Player entered box area and hasn't taken damage from this box yet
					print("Hit box: ", box_area.get_meta("box_id", "unknown"))
					box_area.set_meta("damage_dealt", true)  # Mark as damaged
					_on_obstacle_hit()
					break

func check_colored_obstacle_collision():
	# Check for colored obstacle collisions using area detection (not physics collision)
	if not is_inside_tree():
		return  # Not in scene tree yet
	
	var obstacle_areas = get_tree().get_nodes_in_group("colored_obstacles")
	for obstacle_area in obstacle_areas:
		if obstacle_area is Area3D:
			var overlapping_bodies = obstacle_area.get_overlapping_bodies()
			for body in overlapping_bodies:
				if body == self and not obstacle_area.get_meta("damage_dealt", false):
					# Player entered colored obstacle area and hasn't taken damage from this obstacle yet
					print("Hit colored obstacle: ", obstacle_area.get_meta("obstacle_id", "unknown"))
					obstacle_area.set_meta("damage_dealt", true)  # Mark as damaged
					_on_obstacle_hit()
					break
