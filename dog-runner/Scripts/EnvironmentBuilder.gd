extends Node3D

# ============================================
# PROFESSIONAL AAA ENVIRONMENT BUILDER
# Underground Lab Environment with Full Asset Integration
# ============================================

# --- Voxel Mines Pack Assets ---
const STONE_BLOCK = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/stone-block.glb"
const DARK_STONE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/dark-stone-block.glb"
const STONE_PILLAR = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/stone-pillar.glb"
const LANTERN = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/lantern.glb"
const STONE_FENCE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/stone-fence.glb"
const MINECART = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/minecart.glb"
const COAL_PIECE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/coal-piece.glb"
const GOLD_FRAGMENT = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/gold-fragment.glb"
const DIAMOND_FRAGMENT = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/diamond-fragment.glb"
const SILVER_FRAGMENT = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/silver-fragment.glb"
const STONE_01 = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/stone-01.glb"
const STONE_02 = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/stone-02.glb"
const STONE_GATE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/stone-gate.glb"
const PICKAXE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/pickaxe.glb"
const TRAIN_TRAIL = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/train-trail.glb"
const WOOD_TABLE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/wood-table.glb"
const SILVER_STONE = "res://Assets/Enviroment/kyrises-voxel-mines-environment-pack/glTF/silver-stone.glb"

# --- Pit Asset ---
const PIT = "res://Assets/low_poly_pit.glb"

# --- Kenney Dungeon Kit Assets ---
const CORRIDOR = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/corridor.glb"
const CORRIDOR_WIDE = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/corridor-wide.glb"
const GATE = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/gate.glb"
const TEMPLATE_FLOOR = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/template-floor.glb"
const TEMPLATE_WALL = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/template-wall.glb"
const TEMPLATE_WALL_CORNER = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/template-wall-corner.glb"
const STAIRS = "res://Assets/Enviroment/kenney_modular-dungeon-kit_1.0/Models/GLB format/stairs.glb"

# --- Kenney Conveyor Kit Assets ---
const CONVEYOR = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/conveyor.glb"
const CONVEYOR_STRIPE = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/conveyor-stripe.glb"
const SCANNER_LOW = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/scanner-low.glb"
const SCANNER_HIGH = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/scanner-high.glb"
const STRUCTURE_SHORT = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/structure-short.glb"
const STRUCTURE_MEDIUM = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/structure-medium.glb"
const STRUCTURE_HIGH = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/structure-high.glb"
const BOX_SMALL = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/box-small.glb"
const BOX_LARGE = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/box-large.glb"
const ROBOT_ARM_A = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/robot-arm-a.glb"
const ROBOT_ARM_B = "res://Assets/Enviroment/kenney_conveyor-kit/Models/GLB format/robot-arm-b.glb"

# --- Kenney Industrial Assets ---
const BUILDING_A = "res://Assets/Enviroment/kenney_city-kit-industrial_1.0/Models/GLB format/building-a.glb"
const BUILDING_B = "res://Assets/Enviroment/kenney_city-kit-industrial_1.0/Models/GLB format/building-b.glb"
const CHIMNEY_SMALL = "res://Assets/Enviroment/kenney_city-kit-industrial_1.0/Models/GLB format/chimney-small.glb"

# Preloaded assets dictionary
var assets: Dictionary = {}

# Environment dimensions
const TUNNEL_WIDTH: float = 11.0  # Wider floor for better gameplay space
const TUNNEL_HEIGHT: float = 6.5  # Increased height for enclosed feel
const SEGMENT_LENGTH: float = 20.0
const SCALE_FACTOR_VOXEL: float = 0.22  # Voxel mines scale
const SCALE_FACTOR_KENNEY: float = 0.15  # Kenney assets scale (smaller)

# Environment Phase System
enum EnvironmentPhase { LAB_ESCAPE, DEEP_TUNNELS, TOXIC_ZONE, REACTOR_CORE, FINAL_COLLAPSE }
var current_phase: EnvironmentPhase = EnvironmentPhase.LAB_ESCAPE
var phase_light_colors: Dictionary = {
	EnvironmentPhase.LAB_ESCAPE: Color(1.0, 0.8, 0.4),  # Warm yellow
	EnvironmentPhase.DEEP_TUNNELS: Color(0.6, 0.7, 0.9),  # Cool blue
	EnvironmentPhase.TOXIC_ZONE: Color(0.3, 1.0, 0.3),  # Toxic green
	EnvironmentPhase.REACTOR_CORE: Color(1.0, 0.3, 0.2),  # Red alert
	EnvironmentPhase.FINAL_COLLAPSE: Color(1.0, 0.5, 0.0)  # Orange chaos
}

# Difficulty tracking (set by GameManager)
var obstacle_spawn_chance: float = 0.0
var difficulty_multiplier: float = 1.0

func _ready():
	preload_assets()

func preload_assets():
	# Voxel Mines Pack
	assets["stone_block"] = load(STONE_BLOCK)
	assets["dark_stone"] = load(DARK_STONE)
	assets["pillar"] = load(STONE_PILLAR)
	assets["lantern"] = load(LANTERN)
	assets["fence"] = load(STONE_FENCE)
	assets["minecart"] = load(MINECART)
	assets["coal"] = load(COAL_PIECE)
	assets["gold"] = load(GOLD_FRAGMENT)
	assets["diamond"] = load(DIAMOND_FRAGMENT)
	assets["silver"] = load(SILVER_FRAGMENT)
	assets["stone_01"] = load(STONE_01)
	assets["stone_02"] = load(STONE_02)
	assets["stone_gate"] = load(STONE_GATE)
	assets["pickaxe"] = load(PICKAXE)
	assets["train_trail"] = load(TRAIN_TRAIL)
	assets["wood_table"] = load(WOOD_TABLE)
	assets["silver_stone"] = load(SILVER_STONE)
	
	# Pit Asset
	assets["pit"] = load(PIT)
	
	# Kenney Dungeon Kit
	assets["corridor"] = load(CORRIDOR)
	assets["corridor_wide"] = load(CORRIDOR_WIDE)
	assets["gate"] = load(GATE)
	assets["template_floor"] = load(TEMPLATE_FLOOR)
	assets["template_wall"] = load(TEMPLATE_WALL)
	assets["template_wall_corner"] = load(TEMPLATE_WALL_CORNER)
	assets["stairs"] = load(STAIRS)
	
	# Kenney Conveyor Kit
	assets["conveyor"] = load(CONVEYOR)
	assets["conveyor_stripe"] = load(CONVEYOR_STRIPE)
	assets["scanner_low"] = load(SCANNER_LOW)
	assets["scanner_high"] = load(SCANNER_HIGH)
	assets["structure_short"] = load(STRUCTURE_SHORT)
	assets["structure_medium"] = load(STRUCTURE_MEDIUM)
	assets["structure_high"] = load(STRUCTURE_HIGH)
	assets["box_small"] = load(BOX_SMALL)
	assets["box_large"] = load(BOX_LARGE)
	assets["robot_arm_a"] = load(ROBOT_ARM_A)
	assets["robot_arm_b"] = load(ROBOT_ARM_B)
	
	# Kenney Industrial
	assets["building_a"] = load(BUILDING_A)
	assets["building_b"] = load(BUILDING_B)
	assets["chimney_small"] = load(CHIMNEY_SMALL)

func create_tunnel_segment(segment_index: int) -> Node3D:
	var segment = Node3D.new()
	segment.name = "Segment_" + str(segment_index)
	
	# Build environment with all components
	build_professional_floor(segment, segment_index)
	build_enclosed_walls(segment, segment_index)
	build_background_walls(segment, segment_index)
	build_detailed_ceiling(segment, segment_index)
	add_atmospheric_lighting(segment, segment_index)
	
	# Removed: add_props_and_details() to keep only pits in tunnel mode
	
	# Crumbling floors are now integrated into build_professional_floor()
	
	return segment

func create_2d_segment(segment_index: int) -> Node3D:
	var segment = Node3D.new()
	segment.name = "Segment2D_" + str(segment_index)
	
	# Build different floor for World 2 to show new section
	build_world2_floor(segment, segment_index)
	build_enclosed_walls(segment, segment_index)
	build_background_walls(segment, segment_index)
	build_detailed_ceiling(segment, segment_index)
	add_atmospheric_lighting(segment, segment_index)
	add_varied_obstacles(segment, segment_index)  # Add colored obstacles to 2.5D mode
	
	# Removed: add_props_and_details() to remove boxes from 2.5D mode
	
	# No crumbling floors in 2.5D mode
	
	return segment

# ============================================
# WORLD 2 FLOOR SYSTEM (Distinct from World 1)
# ============================================
func build_world2_floor(segment: Node3D, segment_index: int):
	var floor_y := 0.0
	
	# Main floor collision
	var floor_collision := StaticBody3D.new()
	floor_collision.name = "FloorCollision"
	segment.add_child(floor_collision)
	
	var floor_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(TUNNEL_WIDTH, 1.0, SEGMENT_LENGTH)
	floor_shape.shape = box_shape
	floor_shape.position = Vector3(0, -0.5, SEGMENT_LENGTH / 2)
	floor_collision.add_child(floor_shape)
	
	# Professional AAA floor - similar to World 1 but darker and more refined
	for z in range(0, int(SEGMENT_LENGTH) + 2, 1):
		for x in range(-4, 5, 1):
			# Sophisticated pattern - mostly dark stone with occasional regular stone accents
			var tile_type = "dark_stone"
			
			# Add stone_block accents in a refined pattern
			if (x + z) % 5 == 0 or (x % 3 == 0 and z % 4 == 0):
				tile_type = "stone_block"
			
			# Always create normal floor tile (no pits in 2.5D mode)
			var tile := create_voxel_instance(tile_type)
			if tile:
				tile.position = Vector3(x, floor_y, z)
				tile.scale = Vector3(SCALE_FACTOR_VOXEL * 1.05, SCALE_FACTOR_VOXEL * 0.75, SCALE_FACTOR_VOXEL * 1.05)
				# Subtle rotation for organic feel
				if randf() > 0.85:
					tile.rotation_degrees.y = randf_range(-3, 3)
				segment.add_child(tile)
	
	# Edge definition with darker stones
	for z in range(0, int(SEGMENT_LENGTH) + 2, 2):
		for side_x in [-4, 4]:
			var edge_tile := create_voxel_instance("stone_02")
			if edge_tile:
				edge_tile.position = Vector3(side_x, floor_y - 0.1, z)
				edge_tile.scale = Vector3(SCALE_FACTOR_VOXEL * 1.1, SCALE_FACTOR_VOXEL * 0.8, SCALE_FACTOR_VOXEL * 1.1)
				segment.add_child(edge_tile)
	
	# Subtle detail stones for depth
	if segment_index % 2 == 0:
		for i in range(3):
			var detail_stone := create_voxel_instance("stone_01")
			if detail_stone:
				detail_stone.position = Vector3(randf_range(-3, 3), floor_y + 0.05, randf_range(3, 17))
				detail_stone.scale = Vector3(SCALE_FACTOR_VOXEL * 0.5, SCALE_FACTOR_VOXEL * 0.4, SCALE_FACTOR_VOXEL * 0.5)
				detail_stone.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
				segment.add_child(detail_stone)
	
	# Add lane divider lines for clarity
	for z in range(0, int(SEGMENT_LENGTH) + 2, 2):
		# Left lane divider (between left and center)
		var left_divider := create_voxel_instance("silver_block")
		if left_divider:
			left_divider.position = Vector3(-1.25, floor_y + 0.15, z)
			left_divider.scale = Vector3(SCALE_FACTOR_VOXEL * 0.3, SCALE_FACTOR_VOXEL * 0.3, SCALE_FACTOR_VOXEL * 0.8)
			segment.add_child(left_divider)
		
		# Right lane divider (between center and right)
		var right_divider := create_voxel_instance("silver_block")
		if right_divider:
			right_divider.position = Vector3(1.25, floor_y + 0.15, z)
			right_divider.scale = Vector3(SCALE_FACTOR_VOXEL * 0.3, SCALE_FACTOR_VOXEL * 0.3, SCALE_FACTOR_VOXEL * 0.8)
			segment.add_child(right_divider)

# ============================================
# SIMPLE OBSTACLES SYSTEM
# ============================================

# Array of colors for variety
var obstacle_colors: Array = [
	Color(1.0, 0.3, 0.2),   # Red
	Color(1.0, 0.7, 0.2),   # Orange
	Color(1.0, 1.0, 0.2),   # Yellow
	Color(0.2, 1.0, 0.4),   # Green
	Color(0.2, 0.8, 1.0),   # Cyan
	Color(0.8, 0.2, 0.8),   # Purple
]

func add_varied_obstacles(segment: Node3D, segment_index: int):
	# Define lanes for obstacle placement
	var lanes = [-3.0, 0.0, 3.0]  # Left, Center, Right lanes
	
	# Special handling for early 2.5D mode: exactly 2 obstacles spaced evenly
	if segment_index <= 5:
		# Spawn exactly 2 obstacles at fixed positions
		var obstacle_positions = [
			[0.0, 10.0],   # Center lane, middle
			[3.0, 18.0],   # Right lane, late
		]
		
		for pos in obstacle_positions:
			var lane_x = pos[0]
			var z_pos = pos[1]
			var color = obstacle_colors[randi() % obstacle_colors.size()]
			
			# Create simple colored box obstacle
			var obstacle = create_simple_obstacle(Vector3(lane_x, 0, z_pos), color)
			
			if obstacle:
				segment.add_child(obstacle)
	else:
		# Normal random spawning for later segments
		# Randomly place 2-4 obstacles per segment
		var num_obstacles = randi_range(2, 4)
		var used_positions = []  # Track used Z positions to avoid overlap
		
		for i in range(num_obstacles):
			# Random Z position along the segment (avoid edges)
			var z_pos = randf_range(3, SEGMENT_LENGTH - 3)
			
			# Check if too close to existing obstacles
			var too_close = false
			for used_z in used_positions:
				if abs(z_pos - used_z) < 4.0:  # Minimum 4 units apart
					too_close = true
					break
			
			if too_close:
				continue
			
			used_positions.append(z_pos)
			
			# Random lane selection
			var lane_x = lanes[randi() % lanes.size()]
			
			# Random color
			var color = obstacle_colors[randi() % obstacle_colors.size()]
			
			# Create simple colored box obstacle
			var obstacle = create_simple_obstacle(Vector3(lane_x, 0, z_pos), color)
			
			if obstacle:
				segment.add_child(obstacle)

func create_simple_obstacle(pos: Vector3, color: Color) -> StaticBody3D:
	# Create obstacle body - NO PHYSICS COLLISION, only area detection
	var obstacle = StaticBody3D.new()
	obstacle.name = "Obstacle_Box"
	# Don't add to "obstacles" group to avoid physics collision
	
	# Create visual using stone_block
	var visual := create_voxel_instance("stone_block")
	
	if visual:
		visual.scale = Vector3(SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.5)
		obstacle.add_child(visual)
		
		# Apply colored material
		apply_colored_material(visual, color)
	
	# NO physics collision shape - only area detection
	
	# Add area detection for one-time damage (only for 2.5D mode obstacles)
	var obstacle_area = Area3D.new()
	obstacle_area.name = "ObstacleArea"
	obstacle_area.add_to_group("colored_obstacles")  # Add to colored obstacles group
	obstacle.add_child(obstacle_area)
	
	var area_collision = CollisionShape3D.new()
	var area_box = BoxShape3D.new()
	area_box.size = Vector3(2.0, 1.0, 2.0)  # Reduced height to 1.0 for easier jumping
	area_collision.shape = area_box
	area_collision.position = Vector3(0, 0.6, 0)  # Position relative to obstacle
	obstacle_area.add_child(area_collision)
	
	# Mark this obstacle as not yet triggered
	obstacle_area.set_meta("damage_dealt", false)
	obstacle_area.set_meta("obstacle_id", str(int(pos.x)) + "_" + str(int(pos.z)))
	
	# Position obstacle
	obstacle.position = pos
	obstacle.position.y = 0.6
	
	# Add bright colored glow effect
	var glow_light = OmniLight3D.new()
	glow_light.light_color = color
	glow_light.light_energy = 4.0
	glow_light.omni_range = 6.0
	glow_light.position = Vector3(0, 0, 0)
	obstacle.add_child(glow_light)
	
	return obstacle

func apply_colored_material(node: Node3D, color: Color):
	# Apply colored material to all mesh instances in the node
	for child in node.get_children():
		if child is MeshInstance3D:
			var material = StandardMaterial3D.new()
			material.albedo_color = color
			material.emission_enabled = true
			material.emission = color
			material.emission_energy_multiplier = 2.0  # Make it glow
			child.material_override = material
		# Recursively apply to children
		if child.get_child_count() > 0:
			apply_colored_material(child, color)

# ============================================
# 2.5D SIDE-SCROLLING ENVIRONMENT SYSTEM
# ============================================
func build_2d_ground(segment: Node3D, segment_index: int):
	# Continuous ground floor like in the reference image
	var floor_y := 0.0
	
	# Main ground collision
	var floor_collision := StaticBody3D.new()
	floor_collision.name = "GroundCollision"
	segment.add_child(floor_collision)
	
	var floor_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(TUNNEL_WIDTH, 1.0, SEGMENT_LENGTH)
	floor_shape.shape = box_shape
	floor_shape.position = Vector3(0, -0.5, SEGMENT_LENGTH / 2)
	floor_collision.add_child(floor_shape)
	
	# Dense ground tiles for continuous floor with pattern variation
	for z in range(0, int(SEGMENT_LENGTH) + 1, 1):
		for x in range(-5, 6, 1):
			# Alternate between stone types for visual interest
			var tile_type = "stone_block" if (x + z) % 3 != 0 else "dark_stone"
			var tile := create_voxel_instance(tile_type)
			if tile:
				tile.position = Vector3(x, floor_y, z)
				tile.scale = Vector3(SCALE_FACTOR_VOXEL * 1.1, SCALE_FACTOR_VOXEL * 0.8, SCALE_FACTOR_VOXEL * 1.1)
				# Slight rotation for organic feel
				if randf() > 0.8:
					tile.rotation_degrees.y = randf_range(-5, 5)
				segment.add_child(tile)
	
	# Underground layer for depth with varied stones
	for z in range(0, int(SEGMENT_LENGTH) + 1, 2):
		for x in range(-5, 6, 2):
			var underground := create_voxel_instance("dark_stone")
			if underground:
				underground.position = Vector3(x, floor_y - 1.5, z)
				underground.scale = Vector3(SCALE_FACTOR_VOXEL * 1.2, SCALE_FACTOR_VOXEL, SCALE_FACTOR_VOXEL * 1.2)
				segment.add_child(underground)
	
	# Add ground detail elements
	if segment_index % 3 == 0:
		for i in range(2):
			var rock := create_voxel_instance("stone_01")
			if rock:
				rock.position = Vector3(randf_range(-4, 4), floor_y + 0.3, randf_range(2, 18))
				rock.scale = Vector3(SCALE_FACTOR_VOXEL * 0.6, SCALE_FACTOR_VOXEL * 0.6, SCALE_FACTOR_VOXEL * 0.6)
				rock.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
				segment.add_child(rock)

func build_2d_platforms(segment: Node3D, segment_index: int):
	# No platforms - clean environment
	pass

func build_single_platform(segment: Node3D, pos: Vector3, width: int, depth: int):
	# Build platform with blocks
	for x in range(-width/2, width/2 + 1):
		for z in range(-depth/2, depth/2 + 1):
			var block := create_voxel_instance("stone_block")
			if block:
				block.position = Vector3(pos.x + x, pos.y, pos.z + z)
				block.scale = Vector3(SCALE_FACTOR_VOXEL * 1.1, SCALE_FACTOR_VOXEL * 0.8, SCALE_FACTOR_VOXEL * 1.1)
				segment.add_child(block)
	
	# Platform collision
	var collision = StaticBody3D.new()
	collision.name = "PlatformCollision"
	segment.add_child(collision)
	
	var shape = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(width * 1.0, 0.8, depth * 1.0)
	shape.shape = box
	shape.position = pos
	collision.add_child(shape)

func build_2d_background_elements(segment: Node3D, segment_index: int):
	# Add background decorative elements for depth and atmosphere
	
	# Background pillars/structures at varied positions on both sides
	if segment_index % 3 == 0:
		for side in [-1, 1]:
			var pillar := create_voxel_instance("pillar")
			if pillar:
				pillar.position = Vector3(side * 7, 4, randf_range(5, 15))
				pillar.scale = Vector3(SCALE_FACTOR_VOXEL * 0.8, SCALE_FACTOR_VOXEL * 4, SCALE_FACTOR_VOXEL * 0.8)
				segment.add_child(pillar)
			
			# Add lanterns on pillars
			var lantern := create_voxel_instance("lantern")
			if lantern:
				lantern.position = Vector3(side * 7, 6, randf_range(5, 15))
				lantern.scale = Vector3(SCALE_FACTOR_VOXEL * 0.6, SCALE_FACTOR_VOXEL * 0.6, SCALE_FACTOR_VOXEL * 0.6)
				segment.add_child(lantern)
	
	# Large continuous wall on the right side
	for z in range(0, int(SEGMENT_LENGTH) + 1, 2):
		# Main pillars - larger and taller
		if z % 4 == 0:
			var right_pillar := create_voxel_instance("pillar")
			if right_pillar:
				right_pillar.position = Vector3(6, 4.5, z)
				right_pillar.scale = Vector3(SCALE_FACTOR_VOXEL * 1.2, SCALE_FACTOR_VOXEL * 5.0, SCALE_FACTOR_VOXEL * 1.2)
				segment.add_child(right_pillar)
		
		# Dense wall blocks - multiple layers
		for y in range(0, 8, 1):
			var wall_stone := create_voxel_instance("dark_stone")
			if wall_stone:
				wall_stone.position = Vector3(6.5, y + 0.5, z)
				wall_stone.scale = Vector3(SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.2, SCALE_FACTOR_VOXEL * 1.2)
				segment.add_child(wall_stone)
		
		# Additional depth layer
		if z % 2 == 0:
			for y in range(1, 7, 2):
				var depth_stone := create_voxel_instance("stone_block")
				if depth_stone:
					depth_stone.position = Vector3(7.5, y, z)
					depth_stone.scale = Vector3(SCALE_FACTOR_VOXEL * 1.3, SCALE_FACTOR_VOXEL * 1.3, SCALE_FACTOR_VOXEL * 1.3)
					segment.add_child(depth_stone)
	
	# Clean environment - no obstacles or props

func add_2d_lighting(segment: Node3D, segment_index: int):
	# Simple clean lighting for 2.5D scene
	
	# Main ambient light from above
	var ambient_light = OmniLight3D.new()
	ambient_light.light_color = Color(1.0, 1.0, 1.0)  # Pure white
	ambient_light.light_energy = 1.5
	ambient_light.omni_range = 30.0
	ambient_light.position = Vector3(0, 12, SEGMENT_LENGTH / 2)
	segment.add_child(ambient_light)
	
	# Simple wall lanterns
	for z in range(5, int(SEGMENT_LENGTH), 8):
		var lantern := create_voxel_instance("lantern")
		if lantern:
			lantern.position = Vector3(6, 3, z)
			lantern.scale = Vector3(SCALE_FACTOR_VOXEL * 0.7, SCALE_FACTOR_VOXEL * 0.7, SCALE_FACTOR_VOXEL * 0.7)
			segment.add_child(lantern)
		
		# Soft wall light
		var wall_light = OmniLight3D.new()
		wall_light.light_color = Color(1.0, 0.9, 0.7)
		wall_light.light_energy = 1.2
		wall_light.omni_range = 10.0
		wall_light.position = Vector3(6, 3, z)
		segment.add_child(wall_light)

# ============================================
# PROFESSIONAL FLOOR SYSTEM
# ============================================
func build_professional_floor(segment: Node3D, segment_index: int):
	var floor_y := 0.0
	
	# Main floor collision
	var floor_collision := StaticBody3D.new()
	floor_collision.name = "FloorCollision"
	segment.add_child(floor_collision)
	
	var floor_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(TUNNEL_WIDTH, 0.5, SEGMENT_LENGTH)
	floor_shape.shape = box_shape
	floor_shape.position = Vector3(0, -0.25, SEGMENT_LENGTH / 2)
	floor_collision.add_child(floor_shape)
	
	# Detailed floor tiles with variety - 2 unit spacing
	# Start at z=0 to avoid gap at start
	for z in range(0, int(SEGMENT_LENGTH) + 1, 2):  # Every 2 units, include end
		# Decide if we should spawn a pit at this z position
		var should_spawn_pit = false
		var pit_lane = 0
		
		if segment_index >= 1 and z >= 4 and z <= SEGMENT_LENGTH - 4 and randf() < 0.10:
			should_spawn_pit = true
			# Randomly choose which lane gets the pit
			var lane_options = [-2.15, 0, 2.15]  # Left, Center, Right lanes (matching player lanes)
			pit_lane = lane_options[randi() % lane_options.size()]
		
		# Main floor tiles (playable area) - create tiles except where pits are
		for x in [-4, -2, 0, 2, 4]:
			var is_edge: bool = abs(x) >= 4
			var tile_name: String
			
			# Mix stone types for variety
			if segment_index % 4 == 0 and z % 6 == 0:
				tile_name = "silver_stone" if is_edge else "stone_02"
			else:
				tile_name = "dark_stone" if is_edge else "stone_block"
			
			# Skip tile creation if there's a pit at this position
			var skip_tile = false
			if should_spawn_pit:
				# Map pit lane to closest tile position
				var pit_tile_x = 0
				if pit_lane == -2.15:
					pit_tile_x = -2
				elif pit_lane == 0:
					pit_tile_x = 0
				elif pit_lane == 2.15:
					pit_tile_x = 2
				
				if x == pit_tile_x:
					skip_tile = true
			
			if not skip_tile:
				# Create floor tile
				var tile := create_voxel_instance(tile_name)
				if tile:
					var jitter_y: float = 0.05 if (z % 4 == 0 and randf() > 0.7) else 0.0
					tile.position = Vector3(x, floor_y + jitter_y, z)
					# Slight random rotation for natural look
					if randf() > 0.8:
						tile.rotation_degrees = Vector3(0, randf_range(-5, 5), 0)
					segment.add_child(tile)
		
		# Create pit if needed (replaces the tile)
		if should_spawn_pit:
			# Create pit with collision for damage detection
			var pit := create_voxel_instance("pit")
			if pit:
				pit.position = Vector3(pit_lane, floor_y + 0.5, z)  # Place at the chosen lane position
				pit.scale = Vector3(SCALE_FACTOR_VOXEL * 2.0, SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 2.0)
				# Slight random rotation for natural look
				if randf() > 0.8:
					pit.rotation_degrees = Vector3(0, randf_range(-10, 10), 0)
				
				# Add collision area for pit damage
				var pit_area = Area3D.new()
				pit_area.name = "PitArea"
				pit_area.add_to_group("pits")  # Add to pits group
				pit.add_child(pit_area)
				
				var collision = CollisionShape3D.new()
				var box = BoxShape3D.new()
				box.size = Vector3(2.0, 1.0, 2.0)  # Collision box size
				collision.shape = box
				collision.position = Vector3(0, 0.25, 0)  # Position relative to pit
				pit_area.add_child(collision)
				
				# Mark this pit as not yet triggered
				pit_area.set_meta("damage_dealt", false)
				pit_area.set_meta("pit_id", str(segment_index) + "_" + str(pit_lane) + "_" + str(z))
				
				segment.add_child(pit)
		
		# Extended floor tiles to fill void on sides - cover background wall area
		for x in [-7, -6, -5, 5, 6, 7]:
			var bg_tile := create_voxel_instance("dark_stone")
			if bg_tile:
				bg_tile.position = Vector3(x, floor_y, z)
				bg_tile.scale = Vector3(SCALE_FACTOR_VOXEL * 1.2, SCALE_FACTOR_VOXEL, SCALE_FACTOR_VOXEL * 1.2)
				segment.add_child(bg_tile)
	# Removed: floor templates and train tracks

# ============================================
# ENCLOSED WALL SYSTEM
# ============================================
func build_enclosed_walls(segment: Node3D, segment_index: int):
	var wall_height = TUNNEL_HEIGHT
	
	# Wall collision
	var left_wall_collision = StaticBody3D.new()
	left_wall_collision.name = "LeftWallCollision"
	left_wall_collision.add_to_group("left_wall")
	segment.add_child(left_wall_collision)
	
	var left_wall_shape = CollisionShape3D.new()
	var left_box = BoxShape3D.new()
	left_box.size = Vector3(0.5, wall_height, SEGMENT_LENGTH)
	left_wall_shape.shape = left_box
	left_wall_shape.position = Vector3(-TUNNEL_WIDTH/2 - 0.25, wall_height/2, SEGMENT_LENGTH/2)
	left_wall_collision.add_child(left_wall_shape)
	
	var right_wall_collision = StaticBody3D.new()
	right_wall_collision.name = "RightWallCollision"
	segment.add_child(right_wall_collision)
	
	var right_wall_shape = CollisionShape3D.new()
	var right_box = BoxShape3D.new()
	right_box.size = Vector3(0.5, wall_height, SEGMENT_LENGTH)
	right_wall_shape.shape = right_box
	right_wall_shape.position = Vector3(TUNNEL_WIDTH/2 + 0.25, wall_height/2, SEGMENT_LENGTH/2)
	right_wall_collision.add_child(right_wall_shape)
	
	# Visual walls - mix of voxel pillars and Kenney walls
	for z in range(0, int(SEGMENT_LENGTH) + 4, 4):
		# Left wall - Voxel pillars
		var left_pillar := create_voxel_instance("pillar")
		if left_pillar:
			left_pillar.position = Vector3(-TUNNEL_WIDTH/2, wall_height/2, z)
			left_pillar.scale = Vector3(SCALE_FACTOR_VOXEL * 1.2, SCALE_FACTOR_VOXEL * 3.5, SCALE_FACTOR_VOXEL * 1.2)
			left_pillar.add_to_group("left_wall")
			segment.add_child(left_pillar)
		
		# Fence details between pillars
		if z < SEGMENT_LENGTH - 2:
			var left_fence := create_voxel_instance("fence")
			if left_fence:
				left_fence.position = Vector3(-TUNNEL_WIDTH/2, 1.2, z + 2)
				left_fence.rotation_degrees = Vector3(0, 90, 0)
				left_fence.add_to_group("left_wall")
				segment.add_child(left_fence)
		
		# Right wall - Voxel pillars
		var right_pillar := create_voxel_instance("pillar")
		if right_pillar:
			right_pillar.position = Vector3(TUNNEL_WIDTH/2, wall_height/2, z)
			right_pillar.scale = Vector3(SCALE_FACTOR_VOXEL * 1.2, SCALE_FACTOR_VOXEL * 3.5, SCALE_FACTOR_VOXEL * 1.2)
			segment.add_child(right_pillar)
		
		# Fence details
		if z < SEGMENT_LENGTH - 2:
			var right_fence := create_voxel_instance("fence")
			if right_fence:
				right_fence.position = Vector3(TUNNEL_WIDTH/2, 1.2, z + 2)
				right_fence.rotation_degrees = Vector3(0, 90, 0)
				segment.add_child(right_fence)
	
	# Add Kenney wall templates for variety
	if segment_index % 6 == 0:
		# Left Kenney wall section
		var left_wall_template := create_kenney_instance("template_wall")
		if left_wall_template:
			left_wall_template.position = Vector3(-TUNNEL_WIDTH/2, wall_height/2, SEGMENT_LENGTH / 2)
			left_wall_template.rotation_degrees = Vector3(0, 90, 0)
			left_wall_template.scale = Vector3(SCALE_FACTOR_KENNEY * 1.5, SCALE_FACTOR_KENNEY * 2, SCALE_FACTOR_KENNEY * 2)
			left_wall_template.add_to_group("left_wall")
			segment.add_child(left_wall_template)
		
		# Right Kenney wall section
		var right_wall_template := create_kenney_instance("template_wall")
		if right_wall_template:
			right_wall_template.position = Vector3(TUNNEL_WIDTH/2, wall_height/2, SEGMENT_LENGTH / 2)
			right_wall_template.rotation_degrees = Vector3(0, -90, 0)
			right_wall_template.scale = Vector3(SCALE_FACTOR_KENNEY * 1.5, SCALE_FACTOR_KENNEY * 2, SCALE_FACTOR_KENNEY * 2)
			segment.add_child(right_wall_template)

# ============================================
# BACKGROUND WALLS (Only on Pillar Sides)
# ============================================
func build_background_walls(segment: Node3D, segment_index: int):
	# Add background walls only on the pillar sides (left and right)
	# This prevents seeing empty space on the sides
	var wall_height = TUNNEL_HEIGHT
	var background_distance = 3.0  # Distance behind main walls
	
	# Left background wall (pillar side) - only above floor level
	for z in range(0, int(SEGMENT_LENGTH) + 3, 3):
		for y in range(1, int(wall_height), 2):  # Start from y=1, not y=0
			var bg_stone := create_voxel_instance("dark_stone")
			if bg_stone:
				bg_stone.position = Vector3(-TUNNEL_WIDTH/2 - background_distance, y + 1, z)
				bg_stone.scale = Vector3(SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.5)
				bg_stone.add_to_group("left_wall")
				segment.add_child(bg_stone)
	
	# Right background wall (pillar side) - only above floor level
	for z in range(0, int(SEGMENT_LENGTH) + 3, 3):
		for y in range(1, int(wall_height), 2):  # Start from y=1, not y=0
			var bg_stone := create_voxel_instance("dark_stone")
			if bg_stone:
				bg_stone.position = Vector3(TUNNEL_WIDTH/2 + background_distance, y + 1, z)
				bg_stone.scale = Vector3(SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.5, SCALE_FACTOR_VOXEL * 1.5)
				segment.add_child(bg_stone)
	
	# No back wall - only pillar sides

# ============================================
# DETAILED CEILING SYSTEM
# ============================================
func build_detailed_ceiling(segment: Node3D, segment_index: int):
	var ceiling_y = TUNNEL_HEIGHT
	
	# Dense ceiling with variety - only main area to avoid floor interference
	for z in range(0, int(SEGMENT_LENGTH) + 2, 2):
		# Main ceiling tiles - including center (x=0)
		for x in range(-4, 5, 2):
			var stone_type = "stone_01" if (z + x) % 4 == 0 else "stone_02"
			var stone := create_voxel_instance(stone_type)
			if stone:
				stone.position = Vector3(x, ceiling_y, z)
				# Random rotation for natural look
				stone.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
				# Slight height variation
				var height_jitter = randf_range(-0.1, 0.1) if randf() > 0.7 else 0.0
				stone.position.y += height_jitter
				stone.add_to_group("ceiling")
				segment.add_child(stone)
	
	# Removed: extended ceiling tiles to prevent floor interference
	
	# Removed: hanging lanterns from center

# ============================================
# ATMOSPHERIC LIGHTING SYSTEM
# ============================================
func add_atmospheric_lighting(segment: Node3D, segment_index: int):
	# Get phase-based lighting color and intensity
	var light_color = get_phase_light_color()
	var intensity_mult = get_phase_intensity_multiplier()
	
	# Primary lanterns on walls
	for z in range(2, int(SEGMENT_LENGTH), 6):
		# Left wall lantern
		var left_lantern := create_voxel_instance("lantern")
		if left_lantern:
			left_lantern.position = Vector3(-TUNNEL_WIDTH/2 + 0.3, 2.5, z)
			left_lantern.rotation_degrees = Vector3(0, 90, 0)
			left_lantern.add_to_group("left_wall")
			segment.add_child(left_lantern)
			
			var left_light = OmniLight3D.new()
			left_light.light_color = light_color
			left_light.light_energy = 2.5 * intensity_mult
			left_light.omni_range = 10.0
			left_light.position = Vector3(-TUNNEL_WIDTH/2 + 0.3, 2.5, z)
			left_light.add_to_group("left_wall")
			segment.add_child(left_light)
		
		# Right wall lantern
		var right_lantern := create_voxel_instance("lantern")
		if right_lantern:
			right_lantern.position = Vector3(TUNNEL_WIDTH/2 - 0.3, 2.5, z)
			right_lantern.rotation_degrees = Vector3(0, -90, 0)
			segment.add_child(right_lantern)
			
			var right_light = OmniLight3D.new()
			right_light.light_color = light_color
			right_light.light_energy = 2.5 * intensity_mult
			right_light.omni_range = 10.0
			right_light.position = Vector3(TUNNEL_WIDTH/2 - 0.3, 2.5, z)
			segment.add_child(right_light)
	
	# Additional accent lighting with phase color
	if segment_index % 3 == 0:
		var center_light = OmniLight3D.new()
		center_light.light_color = light_color
		center_light.light_energy = 1.0 * intensity_mult
		center_light.omni_range = 8.0
		center_light.position = Vector3(0, 4.0, SEGMENT_LENGTH / 2)
		segment.add_child(center_light)

# ============================================
# INDUSTRIAL ELEMENTS
# ============================================
func add_industrial_elements(segment: Node3D, segment_index: int):
	# Conveyor belts
	if segment_index % 4 == 0:
		var conveyor := create_kenney_instance("conveyor")
		if conveyor:
			conveyor.position = Vector3(0, 0.3, SEGMENT_LENGTH / 2)
			conveyor.scale = Vector3(SCALE_FACTOR_KENNEY * 1.2, SCALE_FACTOR_KENNEY, SCALE_FACTOR_KENNEY * 2)
			segment.add_child(conveyor)
	
	# Industrial structures on sides
	if segment_index % 5 == 0:
		var left_structure := create_kenney_instance("structure_medium")
		if left_structure:
			left_structure.position = Vector3(-TUNNEL_WIDTH/2 - 1.5, 1.5, SEGMENT_LENGTH / 2)
			left_structure.rotation_degrees = Vector3(0, 90, 0)
			left_structure.scale = Vector3(SCALE_FACTOR_KENNEY * 1.5, SCALE_FACTOR_KENNEY * 1.5, SCALE_FACTOR_KENNEY * 1.5)
			segment.add_child(left_structure)
		
		var right_structure := create_kenney_instance("structure_short")
		if right_structure:
			right_structure.position = Vector3(TUNNEL_WIDTH/2 + 1.5, 1.5, SEGMENT_LENGTH / 2)
			right_structure.rotation_degrees = Vector3(0, -90, 0)
			right_structure.scale = Vector3(SCALE_FACTOR_KENNEY * 1.5, SCALE_FACTOR_KENNEY * 1.5, SCALE_FACTOR_KENNEY * 1.5)
			segment.add_child(right_structure)
	
	# Scanners (future obstacles)
	if segment_index % 6 == 0:
		var scanner := create_kenney_instance("scanner_low")
		if scanner:
			scanner.position = Vector3(0, 2.0, SEGMENT_LENGTH / 2)
			scanner.scale = Vector3(SCALE_FACTOR_KENNEY * 1.2, SCALE_FACTOR_KENNEY * 1.2, SCALE_FACTOR_KENNEY * 1.2)
			segment.add_child(scanner)
			
			# Scanner light effect
			var scanner_light = OmniLight3D.new()
			scanner_light.light_color = Color(0.0, 1.0, 1.0)  # Cyan
			scanner_light.light_energy = 1.5
			scanner_light.omni_range = 5.0
			scanner_light.position = Vector3(0, 2.0, SEGMENT_LENGTH / 2)
			segment.add_child(scanner_light)
	
	# Robot arms (decorative)
	if segment_index % 8 == 0:
		var robot_arm := create_kenney_instance("robot_arm_a" if segment_index % 2 == 0 else "robot_arm_b")
		if robot_arm:
			var side = 1 if randf() > 0.5 else -1
			robot_arm.position = Vector3(side * 3, 2.5, SEGMENT_LENGTH / 2)
			robot_arm.rotation_degrees = Vector3(0, side * 90, 0)
			robot_arm.scale = Vector3(SCALE_FACTOR_KENNEY * 1.3, SCALE_FACTOR_KENNEY * 1.3, SCALE_FACTOR_KENNEY * 1.3)
			segment.add_child(robot_arm)

func get_box_spawn_interval(segment_index: int, game_mode: String) -> int:
	# Progressive difficulty: boxes spawn more frequently as game progresses
	# Start easy and get harder
	
	var base_interval = 4  # Default interval
	
	# Make 2.5D mode slightly easier initially (fewer boxes)
	if game_mode == "2.5d":
		base_interval = 2  # More boxes in 2.5D mode for testing
	
	# Progressive difficulty based on segment index
	if segment_index < 8:
		# Very early game: spawn every 10-12 segments (tutorial mode)
		base_interval = 10 + randi_range(0, 2)
	elif segment_index < 15:
		# Early game: spawn every 8-10 segments (very easy)
		base_interval = 8 + randi_range(0, 2)
	elif segment_index < 25:
		# Mid-early game: spawn every 6-8 segments (easy)
		base_interval = 6 + randi_range(0, 2)
	elif segment_index < 35:
		# Mid game: spawn every 4-6 segments (medium)
		base_interval = 4 + randi_range(0, 2)
	else:
		# Late game: spawn every 3-4 segments (hard)
		base_interval = 3 + randi_range(0, 1)
	
	return base_interval
func add_props_and_details(segment: Node3D, segment_index: int, game_mode: String = "tunnel"):
	# Minecarts
	if segment_index % 3 == 0:
		var cart := create_voxel_instance("minecart")
		if cart:
			var side = 1 if randf() > 0.5 else -1
			cart.position = Vector3(side * 3.5, 0.5, randf_range(5, 15))
			cart.rotation_degrees = Vector3(0, randf_range(-30, 30), 0)
			cart.add_to_group("obstacles")  # Add to obstacles group
			segment.add_child(cart)
	
	# Boxes (industrial debris) - progressive difficulty
	var box_spawn_interval = get_box_spawn_interval(segment_index, game_mode)
	if segment_index % box_spawn_interval == 0:
		var box_type = "box_small" if randf() > 0.5 else "box_large"
		var box_visual := create_kenney_instance(box_type)
		if box_visual:
			# Create StaticBody3D as the root for collision
			var box = StaticBody3D.new()
			box.name = "BoxObstacle"
			box.collision_layer = 1  # Default layer
			box.collision_mask = 1   # Collide with default layer
			
			var side = 1 if randf() > 0.5 else -1
			box.position = Vector3(side * 2.5, 0.3, randf_range(6, 14))
			box.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
			
			# Add the visual as a child
			box.add_child(box_visual)
			box_visual.position = Vector3(0, 0, 0)  # Reset position relative to body
			box_visual.rotation_degrees = Vector3(0, 0, 0)  # Reset rotation
			
			# Add collision shape for blocking player - make it very large to ensure blocking
			var collision_shape = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(3.0, 4.0, 3.0)  # Very large collision box
			collision_shape.shape = box_shape
			collision_shape.position = Vector3(0, 2.0, 0)  # Position high enough to block player
			box.add_child(collision_shape)
			
			# Add area detection for damage (separate from blocking collision)
			var box_area = Area3D.new()
			box_area.name = "BoxArea"
			box_area.add_to_group("box_obstacles")  # Add to box obstacles group
			box.add_child(box_area)
			
			var area_collision = CollisionShape3D.new()
			var area_box = BoxShape3D.new()
			area_box.size = Vector3(3.5, 4.5, 3.5)  # Slightly larger than blocking collision
			area_collision.shape = area_box
			area_collision.position = Vector3(0, 2.0, 0)  # Position to match blocking collision
			box_area.add_child(area_collision)
			
			# Mark this box as not yet triggered
			box_area.set_meta("damage_dealt", false)
			box_area.set_meta("box_id", str(segment_index) + "_" + str(side) + "_" + str(int(box.position.z)))
			
			box.add_to_group("box_obstacles")  # Add to box obstacles group for area detection
			segment.add_child(box)
	
	# Pickaxes (environmental storytelling) - REMOVED
	
	# Wood tables
	if segment_index % 9 == 0:
		var table := create_voxel_instance("wood_table")
		if table:
			var side = 1 if randf() > 0.5 else -1
			table.position = Vector3(side * 3, 0.4, SEGMENT_LENGTH / 2)
			table.rotation_degrees = Vector3(0, randf_range(-45, 45), 0)
			segment.add_child(table)
	
	# Gates (decorative/obstacle markers) - REMOVED
	
	# Coal pieces (debris)
	if segment_index % 5 == 0:
		for i in range(2):
			var coal := create_voxel_instance("coal")
			if coal:
				coal.position = Vector3(randf_range(-3, 3), 0.2, randf_range(4, 16))
				coal.rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))
				coal.scale = Vector3(SCALE_FACTOR_VOXEL * 0.8, SCALE_FACTOR_VOXEL * 0.8, SCALE_FACTOR_VOXEL * 0.8)
				segment.add_child(coal)

# ============================================
# COLLECTIBLES SYSTEM
# ============================================
func add_collectibles(segment: Node3D, segment_index: int):
	var pattern = randi() % 4
	
	match pattern:
		0:  # Straight line in center lane
			for z in range(5, int(SEGMENT_LENGTH) - 5, 2):
				var coin = create_collectible_coin(Vector3(0, 2, z), "gold")
				segment.add_child(coin)
		
		1:  # Zigzag pattern
			var lane = -3
			for z in range(5, int(SEGMENT_LENGTH) - 5, 3):
				var coin = create_collectible_coin(Vector3(lane, 2, z), "gold")
				segment.add_child(coin)
				lane = -lane
		
		2:  # All three lanes
			for z in range(8, int(SEGMENT_LENGTH) - 8, 2):
				for lane in [-3, 0, 3]:
					var coin = create_collectible_coin(Vector3(lane, 2, z), "gold")
					segment.add_child(coin)
		
		3:  # Mixed collectibles (gold, silver, diamond)
			for z in range(6, int(SEGMENT_LENGTH) - 6, 3):
				var collectible_type = "gold"
				if randf() > 0.85:
					collectible_type = "diamond"  # Rare
				elif randf() > 0.7:
					collectible_type = "silver"
				
				var lane = [-3, 0, 3][randi() % 3]
				var coin = create_collectible_coin(Vector3(lane, 2, z), collectible_type)
				segment.add_child(coin)

func create_collectible_coin(pos: Vector3, type: String = "gold") -> Node3D:
	var collectible = Node3D.new()
	collectible.position = pos
	collectible.name = "Collectible_" + type
	
	# Visual based on type
	var visual := create_voxel_instance(type)
	if visual:
		collectible.add_child(visual)
	
	# Area3D for collision detection
	var area = Area3D.new()
	area.name = "PickupArea"
	collectible.add_child(area)
	
	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5
	collision.shape = sphere
	area.add_child(collision)
	
	return collectible

# ============================================
# ASSET INSTANTIATION HELPERS
# ============================================
func create_voxel_instance(asset_name: String) -> Node3D:
	if not assets.has(asset_name):
		push_warning("Voxel asset not found: " + asset_name)
		return null
	
	var scene = assets[asset_name]
	if scene:
		var instance = scene.instantiate()
		instance.scale = Vector3(SCALE_FACTOR_VOXEL, SCALE_FACTOR_VOXEL, SCALE_FACTOR_VOXEL)
		return instance
	return null

func create_kenney_instance(asset_name: String) -> Node3D:
	if not assets.has(asset_name):
		push_warning("Kenney asset not found: " + asset_name)
		return null
	
	var scene = assets[asset_name]
	if scene:
		var instance = scene.instantiate()
		instance.scale = Vector3(SCALE_FACTOR_KENNEY, SCALE_FACTOR_KENNEY, SCALE_FACTOR_KENNEY)
		return instance
	return null

# ============================================
# CRUMBLING FLOOR SYSTEM
# ============================================

func add_crumbling_floors(segment: Node3D, segment_index: int, difficulty: float):
	# High spawn chance for testing (80%)
	var spawn_chance = 0.8
	
	if randf() > spawn_chance:
		return  # Don't spawn crumbling floors this segment
	
	# Define lanes
	var lanes = [-3.0, 0.0, 3.0]
	
	# Randomly select 1-2 lanes to have crumbling floors
	var num_crumbling_sections = randi_range(1, 2)
	
	for i in range(num_crumbling_sections):
		var lane_x = lanes[randi() % lanes.size()]
		var start_z = randf_range(4, SEGMENT_LENGTH - 8)
		var length = randf_range(3, 6)  # 3-6 units long
		
		# Create crumbling floor section
		for z in range(int(start_z), int(start_z + length), 2):
			var crumbling_tile = create_crumbling_tile(Vector3(lane_x, 0, z))
			if crumbling_tile:
				segment.add_child(crumbling_tile)

func create_crumbling_tile(pos: Vector3) -> Area3D:
	# Use Area3D to detect when player steps on it
	var tile = Area3D.new()
	tile.name = "CrumbleTile"
	tile.add_to_group("crumbling_floors")
	tile.add_to_group("obstacles")  # Add to obstacles group
	tile.position = pos
	
	# Visual - use darker stone to indicate danger
	var visual := create_voxel_instance("dark_stone")
	if visual:
		visual.position = Vector3(0, 0.1, 0)
		visual.scale = Vector3(SCALE_FACTOR_VOXEL * 1.3, SCALE_FACTOR_VOXEL * 0.6, SCALE_FACTOR_VOXEL * 1.3)
		tile.add_child(visual)
	
	# Add cracks visual (using smaller stones)
	for crack_offset in [Vector3(-0.3, 0.15, 0), Vector3(0.3, 0.15, 0), Vector3(0, 0.15, 0.3)]:
		var crack := create_voxel_instance("stone_01")
		if crack:
			crack.position = crack_offset
			crack.scale = Vector3(SCALE_FACTOR_VOXEL * 0.3, SCALE_FACTOR_VOXEL * 0.2, SCALE_FACTOR_VOXEL * 0.3)
			crack.rotation_degrees.y = randf_range(0, 360)
			tile.add_child(crack)
	
	# Collision detection area
	var collision = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(1.5, 0.5, 1.5)
	collision.shape = box
	collision.position = Vector3(0, 0.25, 0)
	tile.add_child(collision)
	
	# Warning light (orange/yellow) - MUCH BRIGHTER
	var warning_light = OmniLight3D.new()
	warning_light.light_color = Color(1.0, 0.6, 0.1)  # Orange warning
	warning_light.light_energy = 3.5  # Increased from 1.2 to 3.5
	warning_light.omni_range = 5.0  # Increased from 2.5 to 5.0
	warning_light.position = Vector3(0, 0.2, 0)
	tile.add_child(warning_light)
	
	# Add colored material to make it more visible
	if visual:
		apply_colored_material(visual, Color(1.0, 0.6, 0.1))
	
	# Store tile state
	tile.set_meta("is_crumbling", false)
	tile.set_meta("crumble_timer", 0.0)
	tile.set_meta("warning_light", warning_light)
	tile.set_meta("visual", visual)
	
	return tile

# ============================================
# ENVIRONMENT PHASE SYSTEM
# ============================================
func set_environment_phase(phase: int):
	current_phase = phase as EnvironmentPhase
	print("EnvironmentBuilder: Phase changed to ", EnvironmentPhase.keys()[current_phase])

func get_phase_light_color() -> Color:
	return phase_light_colors.get(current_phase, Color(1.0, 0.8, 0.4))

func get_phase_intensity_multiplier() -> float:
	# Lighting gets more intense in later phases
	match current_phase:
		EnvironmentPhase.LAB_ESCAPE:
			return 1.0
		EnvironmentPhase.DEEP_TUNNELS:
			return 0.8  # Dimmer
		EnvironmentPhase.TOXIC_ZONE:
			return 1.2  # Brighter toxic glow
		EnvironmentPhase.REACTOR_CORE:
			return 1.5  # Intense red
		EnvironmentPhase.FINAL_COLLAPSE:
			return 2.0  # Chaotic bright
		_:
			return 1.0
