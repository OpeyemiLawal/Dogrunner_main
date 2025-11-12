extends Node3D

# Game state
var game_speed: float = 4.0  # Slower starting speed
var max_speed: float = 12.0  # Reduced max speed for easier gameplay
var speed_increase_rate: float = 0.15  # Slower acceleration
var score: int = 0
var distance: float = 0.0
var is_game_over: bool = false

# Health system
var player_health: int = 100
var max_health: int = 100

# Procedural Evolution System
enum EnvironmentPhase { LAB_ESCAPE, DEEP_TUNNELS, TOXIC_ZONE, REACTOR_CORE, FINAL_COLLAPSE }
var current_phase: EnvironmentPhase = EnvironmentPhase.LAB_ESCAPE
var phase_distance_thresholds: Array = [0, 500, 1000, 1500, 2000]  # Distance to trigger each phase
var phase_colors: Array = [
	Color(1.0, 0.8, 0.4),  # Warm yellow (Lab)
	Color(0.6, 0.7, 0.9),  # Cool blue (Deep Tunnels)
	Color(0.3, 1.0, 0.3),  # Toxic green (Toxic Zone)
	Color(1.0, 0.3, 0.2),  # Red alert (Reactor Core)
	Color(1.0, 0.5, 0.0)   # Orange chaos (Final Collapse)
]

# Difficulty Scaling
var difficulty_multiplier: float = 1.0
var obstacle_spawn_chance: float = 0.0  # Starts at 0, increases with distance
var max_obstacle_chance: float = 0.7
var hazard_intensity: float = 0.0  # Controls laser speed, slime size, etc.
var game_mode: String = "tunnel"  # "tunnel" or "2.5d"
var is_transitioning: bool = false
var transition_progress: float = 0.0
const TRANSITION_DURATION: float = 1.0  # 1 second smooth transition
var time_in_current_mode: float = 0.0
const MODE_SWITCH_INTERVAL: float = 30.0  # Switch modes every 30 seconds
var next_mode: String = "2.5d"

# Level generation
@onready var level_segments: Node3D = $Environment/LevelSegments
var segment_length: float = 20.0
var segments_ahead: int = 5
var current_segment_index: int = 0

# Player reference
@onready var player: CharacterBody3D = $player
@onready var camera: Camera3D = $Camera3D

# HUD reference
@onready var health_label: Label = $"HealthContainer#HealthLabel"

# Environment builder
var environment_builder: Node3D

# Camera manager
var camera_manager: Node3D

# Visual effects
var transition_particles: GPUParticles3D
var speed_lines: GPUParticles3D
var ambient_dust: GPUParticles3D
var impact_sparks: GPUParticles3D
var ground_dust: GPUParticles3D

func _ready():
	# Create environment builder
	environment_builder = load("res://Scripts/EnvironmentBuilder.gd").new()
	add_child(environment_builder)
	
	# Create camera manager
	camera_manager = load("res://Scripts/CameraManager.gd").new()
	camera_manager.camera = camera
	camera_manager.camera_mode = camera_manager.CameraMode.PERSPECTIVE  # Default to perspective
	add_child(camera_manager)
	
	# Initialize visual effects
	setup_visual_effects()
	
	# Store original camera position for shake
	if camera:
		original_camera_position = camera.position
	
	# Initialize health display
	update_health_display()
	
	# Generate initial level
	generate_initial_level()

func _process(delta):
	if is_game_over:
		return
	
	# Increase game speed over time
	if game_speed < max_speed:
		game_speed += speed_increase_rate * delta
	
	# Update distance
	distance += game_speed * delta
	score = int(distance)
	
	# Update procedural evolution
	update_environment_phase()
	
	# Update difficulty scaling
	update_difficulty_scaling()
	
	# Update environment builder with difficulty data
	if environment_builder:
		environment_builder.obstacle_spawn_chance = obstacle_spawn_chance
		environment_builder.difficulty_multiplier = difficulty_multiplier
	
	# Track time in current mode
	if not is_transitioning:
		time_in_current_mode += delta
	
	# Switch modes every 30 seconds
	if time_in_current_mode >= MODE_SWITCH_INTERVAL and not is_transitioning:
		is_transitioning = true
		transition_progress = 0.0
		time_in_current_mode = 0.0
		
		# Trigger visual transition effect
		trigger_transition_effect()
		
		# Toggle between modes
		if game_mode == "tunnel":
			game_mode = "2.5d"
			next_mode = "tunnel"
		else:
			game_mode = "tunnel"
			next_mode = "2.5d"
	
	# Handle smooth camera transition
	if is_transitioning:
		transition_progress += delta / TRANSITION_DURATION
		
		# Fade walls based on which mode we're transitioning to
		if game_mode == "2.5d":
			# Transitioning to 2.5D - fade out walls
			update_left_wall_visibility(1.0 - transition_progress)
			update_ceiling_visibility(1.0 - transition_progress)
			# Forward transition progress for camera
			if camera_manager and camera_manager.has_method("set_transition_progress"):
				camera_manager.set_transition_progress(transition_progress)
		else:
			# Transitioning to tunnel - fade in walls
			update_left_wall_visibility(transition_progress)
			update_ceiling_visibility(transition_progress)
			# Reverse transition progress for camera (from iso back to perspective)
			if camera_manager and camera_manager.has_method("set_transition_progress"):
				camera_manager.set_transition_progress(1.0 - transition_progress)
		
		if transition_progress >= 1.0:
			transition_progress = 1.0
			is_transitioning = false
			if camera_manager and camera_manager.has_method("switch_camera_mode"):
				if game_mode == "2.5d":
					camera_manager.switch_camera_mode(camera_manager.CameraMode.ISOMETRIC)
				else:
					camera_manager.switch_camera_mode(camera_manager.CameraMode.PERSPECTIVE)
	
	# Keep left walls and ceiling invisible in 2.5D mode
	if game_mode == "2.5d" and not is_transitioning:
		update_left_wall_visibility(0.0)
		update_ceiling_visibility(0.0)
	
	# Make left walls and ceiling visible in tunnel mode
	if game_mode == "tunnel" and not is_transitioning:
		update_left_wall_visibility(1.0)
		update_ceiling_visibility(1.0)
	
	# Update camera position to follow player
	if camera_manager:
		camera_manager.update_camera(delta, player)
	
	# Update visual effects
	update_visual_effects()
	
	# Apply screen shake
	apply_screen_shake(delta)
	
	# Generate new level segments
	check_and_generate_segments()

func generate_initial_level():
	# Generate starting segments to eliminate gap (covering negative z)
	for i in range(-2, segments_ahead):
		spawn_segment(i)

func check_and_generate_segments():
	# Check if we need to spawn new segments
	var player_z = player.global_position.z
	var segments_passed = int(player_z / segment_length)
	
	if segments_passed > current_segment_index:
		current_segment_index = segments_passed
		# Keep exactly `segments_ahead` segments in front; avoid skipping an index
		spawn_segment(current_segment_index + segments_ahead - 1)
		
		# Remove old segments
		cleanup_old_segments()


func spawn_segment(index: int):
	var segment = create_tunnel_segment(index)
	segment.position = Vector3(0, 0, index * segment_length)
	level_segments.add_child(segment)

func create_tunnel_segment(index: int) -> Node3D:
	# Use the environment builder to create a professional tunnel segment
	if environment_builder and environment_builder.has_method("create_tunnel_segment"):
		if game_mode == "tunnel":
			return environment_builder.create_tunnel_segment(index)
		elif game_mode == "2.5d":
			return environment_builder.create_2d_segment(index)
		else:
			# Fallback for unknown modes
			var segment = Node3D.new()
			segment.name = "Segment_" + str(index)
			return segment
	else:
		# Fallback: create empty segment
		var segment = Node3D.new()
		segment.name = "Segment_" + str(index)
		return segment

func cleanup_old_segments():
	# Remove segments that are behind the player
	for child in level_segments.get_children():
		if child.position.z < player.global_position.z - segment_length * 2:
			child.queue_free()

func update_left_wall_visibility(opacity: float):
	# Update visibility of all left wall elements
	var left_walls = get_tree().get_nodes_in_group("left_wall")
	for wall in left_walls:
		if wall is Node3D:
			wall.visible = opacity > 0.01

func update_ceiling_visibility(opacity: float):
	# Update visibility of all ceiling elements
	var ceiling_tiles = get_tree().get_nodes_in_group("ceiling")
	for tile in ceiling_tiles:
		if tile is Node3D:
			tile.visible = opacity > 0.01

func game_over():
	# Game over - reload current scene
	print("Game Over! Reloading scene...")
	get_tree().reload_current_scene()

func take_damage(amount: int = 1):
	# Reduce player health
	player_health -= amount
	print("Player took damage! Health: ", player_health, "/", max_health)
	
	# Trigger professional damage visual effect instead of screen shake
	trigger_damage_visual_effect()
	
	# Update health display
	update_health_display()
	
	# Check if player is dead
	if player_health <= 0:
		player_health = 0
		game_over()

func update_health_display():
	# Update the health label on the HUD
	print("update_health_display called - health: ", player_health, "/", max_health)
	if health_label:
		health_label.text = "❤️ " + str(player_health) + "/" + str(max_health)
		print("Health label updated to: ", health_label.text)
		
		# Change color based on health
		if player_health <= 3:
			health_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))  # Red when low
		elif player_health <= 6:
			health_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))  # Yellow when medium
		else:
			health_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))  # White when high
	else:
		print("ERROR: health_label is null!")

func setup_visual_effects():
	# Create transition particle effect
	transition_particles = GPUParticles3D.new()
	transition_particles.name = "TransitionParticles"
	transition_particles.emitting = false
	transition_particles.amount = 100
	transition_particles.lifetime = 1.5
	transition_particles.explosiveness = 0.8
	transition_particles.visibility_aabb = AABB(Vector3(-20, -10, -20), Vector3(40, 20, 40))
	
	var transition_material = ParticleProcessMaterial.new()
	transition_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	transition_material.emission_box_extents = Vector3(5, 3, 2)
	transition_material.direction = Vector3(0, 1, 0)
	transition_material.spread = 45.0
	transition_material.initial_velocity_min = 3.0
	transition_material.initial_velocity_max = 6.0
	transition_material.gravity = Vector3(0, -2, 0)
	transition_material.scale_min = 0.1
	transition_material.scale_max = 0.3
	transition_material.color = Color(0.8, 0.9, 1.0, 0.8)
	transition_particles.process_material = transition_material
	
	add_child(transition_particles)
	
	# Create speed lines effect
	speed_lines = GPUParticles3D.new()
	speed_lines.name = "SpeedLines"
	speed_lines.emitting = true
	speed_lines.amount = 50
	speed_lines.lifetime = 0.5
	speed_lines.visibility_aabb = AABB(Vector3(-15, -10, -5), Vector3(30, 20, 30))
	
	var speed_material = ParticleProcessMaterial.new()
	speed_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	speed_material.emission_box_extents = Vector3(8, 4, 1)
	speed_material.direction = Vector3(0, 0, -1)
	speed_material.spread = 5.0
	speed_material.initial_velocity_min = 15.0
	speed_material.initial_velocity_max = 25.0
	speed_material.gravity = Vector3(0, 0, 0)
	speed_material.scale_min = 0.05
	speed_material.scale_max = 0.15
	speed_material.color = Color(1.0, 1.0, 1.0, 0.3)
	speed_lines.process_material = speed_material
	
	add_child(speed_lines)
	
	# Create ambient dust particles
	ambient_dust = GPUParticles3D.new()
	ambient_dust.name = "AmbientDust"
	ambient_dust.emitting = true
	ambient_dust.amount = 80
	ambient_dust.lifetime = 4.0
	ambient_dust.visibility_aabb = AABB(Vector3(-20, -5, -10), Vector3(40, 15, 40))
	
	var dust_material = ParticleProcessMaterial.new()
	dust_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	dust_material.emission_box_extents = Vector3(10, 5, 10)
	dust_material.direction = Vector3(0, 0.5, -0.2)
	dust_material.spread = 30.0
	dust_material.initial_velocity_min = 0.5
	dust_material.initial_velocity_max = 1.5
	dust_material.gravity = Vector3(0, -0.2, 0)
	dust_material.scale_min = 0.05
	dust_material.scale_max = 0.2
	dust_material.color = Color(0.7, 0.7, 0.6, 0.15)
	ambient_dust.process_material = dust_material
	
	add_child(ambient_dust)
	
	# Create impact sparks effect (for collisions)
	impact_sparks = GPUParticles3D.new()
	impact_sparks.name = "ImpactSparks"
	impact_sparks.emitting = false
	impact_sparks.amount = 30
	impact_sparks.lifetime = 0.8
	impact_sparks.one_shot = true
	impact_sparks.explosiveness = 1.0
	impact_sparks.visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
	
	var spark_material = ParticleProcessMaterial.new()
	spark_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spark_material.emission_sphere_radius = 0.3
	spark_material.direction = Vector3(0, 1, 0)
	spark_material.spread = 180.0
	spark_material.initial_velocity_min = 5.0
	spark_material.initial_velocity_max = 12.0
	spark_material.gravity = Vector3(0, -15, 0)
	spark_material.scale_min = 0.05
	spark_material.scale_max = 0.15
	spark_material.color = Color(1.0, 0.7, 0.2, 1.0)  # Orange sparks
	impact_sparks.process_material = spark_material
	
	add_child(impact_sparks)
	
	# Create ground dust effect (running dust trail)
	ground_dust = GPUParticles3D.new()
	ground_dust.name = "GroundDust"
	ground_dust.emitting = true
	ground_dust.amount = 40
	ground_dust.lifetime = 1.0
	ground_dust.visibility_aabb = AABB(Vector3(-10, -5, -10), Vector3(20, 10, 20))
	
	var ground_material = ParticleProcessMaterial.new()
	ground_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	ground_material.emission_box_extents = Vector3(0.5, 0.1, 0.5)
	ground_material.direction = Vector3(0, 0.5, -0.3)
	ground_material.spread = 25.0
	ground_material.initial_velocity_min = 1.0
	ground_material.initial_velocity_max = 3.0
	ground_material.gravity = Vector3(0, -1, 0)
	ground_material.scale_min = 0.1
	ground_material.scale_max = 0.3
	ground_material.color = Color(0.6, 0.5, 0.4, 0.5)  # Brown dust
	ground_dust.process_material = ground_material
	
	add_child(ground_dust)

func trigger_damage_visual_effect():
	# Professional damage visual effect: screen flash + impact particles
	if player:
		# Trigger impact sparks at player position
		if impact_sparks:
			impact_sparks.global_position = player.global_position + Vector3(0, 1, 0)
			impact_sparks.emitting = true
			impact_sparks.restart()
			# Bright red/orange sparks for damage
			if impact_sparks.process_material:
				impact_sparks.process_material.color = Color(1.0, 0.3, 0.1, 1.0)  # Red-orange
		
		# Create screen flash effect using a temporary color overlay
		create_damage_flash()

func create_damage_flash():
	# Create a temporary screen flash effect
	var flash_overlay = ColorRect.new()
	flash_overlay.name = "DamageFlash"
	flash_overlay.color = Color(1.0, 0.2, 0.2, 0.3)  # Red flash
	flash_overlay.size = Vector2(1920, 1080)  # Full screen
	flash_overlay.position = Vector2(-960, -540)  # Center on screen
	
	# Add to canvas layer for UI overlay
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(flash_overlay)
	add_child(canvas_layer)
	
	# Animate flash fade out
	var tween = create_tween()
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.5)  # Fade out over 0.5 seconds
	tween.tween_callback(func(): canvas_layer.queue_free())  # Remove after fade

func update_visual_effects():
	# Update particle positions to follow player
	if transition_particles and player:
		transition_particles.global_position = player.global_position + Vector3(0, 2, 0)
	
	if speed_lines and player:
		speed_lines.global_position = player.global_position + Vector3(0, 1, 5)
		# Adjust speed lines intensity based on game speed
		var speed_intensity = clamp(game_speed / max_speed, 0.3, 1.0)
		if speed_lines.process_material:
			speed_lines.amount = int(50 * speed_intensity)
	
	if ambient_dust and player:
		ambient_dust.global_position = player.global_position + Vector3(0, 3, 0)
	
	if ground_dust and player:
		ground_dust.global_position = player.global_position + Vector3(0, 0.2, 0)
		# Increase dust based on speed
		var dust_intensity = clamp(game_speed / max_speed, 0.3, 1.0)
		if ground_dust.process_material:
			ground_dust.amount = int(40 * dust_intensity)

func trigger_transition_effect():
	# Trigger visual effect when mode transitions
	if transition_particles:
		transition_particles.emitting = true
		transition_particles.restart()

# ============================================
# PROCEDURAL EVOLUTION SYSTEM
# ============================================
func update_environment_phase():
	# Check if we should transition to next phase
	var next_phase_index = int(current_phase) + 1
	if next_phase_index < phase_distance_thresholds.size():
		if distance >= phase_distance_thresholds[next_phase_index]:
			current_phase = next_phase_index as EnvironmentPhase
			on_phase_transition()

func on_phase_transition():
	# Visual feedback for phase change
	print("Phase Transition: ", EnvironmentPhase.keys()[current_phase])
	
	# Trigger dramatic visual effect
	if transition_particles:
		transition_particles.emitting = true
		transition_particles.restart()
		# Change particle color based on phase
		if transition_particles.process_material:
			transition_particles.process_material.color = phase_colors[current_phase]
	
	# Update environment builder with new phase
	if environment_builder and environment_builder.has_method("set_environment_phase"):
		environment_builder.set_environment_phase(current_phase)
	
	# Increase max speed for higher phases
	max_speed = 15.0 + (current_phase * 3.0)  # +3 speed per phase
	
	# Screen shake effect
	trigger_screen_shake(0.5, 0.3)

func get_phase_name() -> String:
	match current_phase:
		EnvironmentPhase.LAB_ESCAPE:
			return "Lab Escape"
		EnvironmentPhase.DEEP_TUNNELS:
			return "Deep Tunnels"
		EnvironmentPhase.TOXIC_ZONE:
			return "Toxic Zone"
		EnvironmentPhase.REACTOR_CORE:
			return "Reactor Core"
		EnvironmentPhase.FINAL_COLLAPSE:
			return "Final Collapse"
		_:
			return "Unknown"

# ============================================
# DIFFICULTY SCALING SYSTEM
# ============================================
func update_difficulty_scaling():
	# Progressive difficulty increase based on distance
	difficulty_multiplier = 1.0 + (distance / 1000.0)  # +1 difficulty per 1000 units
	
	# Obstacle spawn chance increases with distance
	obstacle_spawn_chance = min(max_obstacle_chance, distance / 2000.0)  # Reaches max at 1400 units
	
	# Hazard intensity (for laser speed, slime spread, etc.)
	hazard_intensity = min(1.0, distance / 1500.0)  # Reaches max at 1500 units
	
	# Speed increase rate scales with difficulty
	speed_increase_rate = 0.2 + (difficulty_multiplier * 0.05)

func get_difficulty_tier() -> String:
	if difficulty_multiplier < 1.5:
		return "Easy"
	elif difficulty_multiplier < 2.5:
		return "Medium"
	elif difficulty_multiplier < 3.5:
		return "Hard"
	else:
		return "Extreme"

# ============================================
# VISUAL EFFECTS SYSTEM
# ============================================
var screen_shake_amount: float = 0.0
var screen_shake_duration: float = 0.0
var original_camera_position: Vector3

func trigger_screen_shake(intensity: float, duration: float):
	screen_shake_amount = intensity
	screen_shake_duration = duration
	if camera:
		original_camera_position = camera.position

func apply_screen_shake(delta: float):
	if screen_shake_duration > 0:
		screen_shake_duration -= delta
		
		if camera:
			# Random shake offset
			var shake_offset = Vector3(
				randf_range(-screen_shake_amount, screen_shake_amount),
				randf_range(-screen_shake_amount, screen_shake_amount),
				0
			)
			camera.position = original_camera_position + shake_offset
			
			# Decay shake
			screen_shake_amount = lerp(screen_shake_amount, 0.0, delta * 5.0)
	else:
		# Reset camera position
		if camera and screen_shake_amount > 0:
			camera.position = original_camera_position
			screen_shake_amount = 0.0

# ============================================
# CRUMBLING FLOOR SYSTEM
# ============================================
func update_crumbling_floors(delta: float):
	# Get all crumbling floor tiles
	var crumbling_tiles = get_tree().get_nodes_in_group("crumbling_floors")
	
	for tile in crumbling_tiles:
		if not tile is Area3D:
			continue
		
		# Check if player is on this tile
		var is_player_on_tile = false
		var overlapping_bodies = tile.get_overlapping_bodies()
		
		for body in overlapping_bodies:
			if body == player:
				is_player_on_tile = true
				break
		
		# Handle crumbling logic
		if is_player_on_tile:
			if not tile.get_meta("is_crumbling"):
				# Start crumbling
				tile.set_meta("is_crumbling", true)
				tile.set_meta("crumble_timer", 0.0)
				
				# Make warning light blink faster
				var warning_light = tile.get_meta("warning_light")
				if warning_light:
					warning_light.light_energy = 2.0
		
		# Update crumbling timer
		if tile.get_meta("is_crumbling"):
			var crumble_timer = tile.get_meta("crumble_timer")
			crumble_timer += delta
			tile.set_meta("crumble_timer", crumble_timer)
			
			# Visual feedback - shake and fade
			var visual = tile.get_meta("visual")
			if visual and crumble_timer < 0.5:
				# Shake effect
				visual.position.y = 0.1 + sin(crumble_timer * 40) * 0.1
				
				# Blink warning light
				var warning_light = tile.get_meta("warning_light")
				if warning_light:
					warning_light.light_energy = 1.2 + sin(crumble_timer * 30) * 0.8
			
			# Collapse after 0.5 seconds
			if crumble_timer >= 0.5:
				trigger_tile_collapse(tile)

func trigger_tile_collapse(tile: Area3D):
	# Spawn collapse particles
	if impact_sparks:
		impact_sparks.global_position = tile.global_position + Vector3(0, 0.5, 0)
		impact_sparks.emitting = true
		impact_sparks.restart()
		
		# Change particle color to brown/gray for debris
		if impact_sparks.process_material:
			impact_sparks.process_material.color = Color(0.5, 0.4, 0.3, 1.0)
	
	# Small screen shake
	trigger_screen_shake(0.2, 0.15)
	
	# Remove the tile
	tile.queue_free()
