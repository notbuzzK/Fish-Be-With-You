# PlayArea.gd
extends Area2D

# Fish Food Scenes to spawn
export (PackedScene) var smol_fish_scene: PackedScene
export (PackedScene) var medium_fish_scene: PackedScene
export (PackedScene) var large_fish_scene: PackedScene

# Spawning parameters
export var initial_fish_count: int = 20
export var max_active_fish_limit: int = 30

onready var spawn_timer = $SpawnTimer
onready var fish_container = $FishContainer
onready var play_area_collision_shape = $CollisionShape2D # Renamed for clarity

var active_fish_nodes = []

func _ready():
	if not smol_fish_scene or not medium_fish_scene or not large_fish_scene:
		print_debug("ERROR: PlayArea - One or more fish scenes not assigned in Inspector!")
		if spawn_timer:
			spawn_timer.stop()
		return

	randomize()

	for i in range(initial_fish_count):
		if active_fish_nodes.size() < max_active_fish_limit:
			spawn_random_fish()
		else:
			break

	if spawn_timer:
		spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
	else:
		print_debug("ERROR: PlayArea - SpawnTimer node not found!")

func _on_SpawnTimer_timeout():
	spawn_fish_if_needed()

func spawn_fish_if_needed():
	var valid_fish = []
	for fish in active_fish_nodes:
		if is_instance_valid(fish):
			valid_fish.append(fish)
	active_fish_nodes = valid_fish

	if active_fish_nodes.size() < max_active_fish_limit:
		spawn_random_fish()

func spawn_random_fish():
	var fish_scene_to_spawn = null
	var rand_choice = randi() % 3

	match rand_choice:
		0: fish_scene_to_spawn = smol_fish_scene
		1: fish_scene_to_spawn = medium_fish_scene
		2: fish_scene_to_spawn = large_fish_scene
	
	if fish_scene_to_spawn:
		var new_fish = fish_scene_to_spawn.instance()
		
		# --- CORRECTED SPAWN POSITION LOGIC ---
		if not play_area_collision_shape or not play_area_collision_shape.shape is RectangleShape2D:
			print_debug("ERROR: PlayArea - PlayArea CollisionShape2D is missing or not a RectangleShape2D!")
			# Fallback to a default spawn or viewport if shape is invalid
			new_fish.global_position = get_viewport_rect().size / 2 # Center of viewport
		else:
			# Get the global position of the CollisionShape2D node itself
			var shape_node_global_position = play_area_collision_shape.global_position
			# Get the extents (half-width, half-height) of the RectangleShape2D
			var extents = play_area_collision_shape.shape.extents

			# Calculate random position within these global bounds
			var random_x = rand_range(shape_node_global_position.x - extents.x, shape_node_global_position.x + extents.x)
			var random_y = rand_range(shape_node_global_position.y - extents.y, shape_node_global_position.y + extents.y)
			
			new_fish.global_position = Vector2(random_x, random_y)
		
		if fish_container:
			fish_container.add_child(new_fish)
		else:
			add_child(new_fish) 
			
		active_fish_nodes.append(new_fish)
	else:
		print_debug("ERROR: PlayArea - Could not determine which fish scene to spawn.")

# Optional: If fish can leave the PlayArea, you might want to handle that
# func _on_PlayArea_body_exited(body): # Make sure signal is connected from PlayArea node
# 	if body in active_fish_nodes:
# 		# This requires the fish themselves to be physics bodies (KinematicBody2D, RigidBody2D)
# 		# or Area2Ds with appropriate collision layers/masks to trigger body_exited on the PlayArea.
# 		# If fish are just Area2Ds, you'd use area_exited.
# 		print_debug("Fish left play area:", body.name)
