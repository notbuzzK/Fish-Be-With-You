# BuffSpawnDespawn.gd
extends Area2D

# === Buff Scenes to Spawn ===
export (PackedScene) var speed_buff_scene: PackedScene
export (PackedScene) var regen_buff_scene: PackedScene
export (PackedScene) var time_buff_scene: PackedScene

# === Spawning Parameters ===
export var initial_buff_count: int = 3
export var max_active_buff_limit: int = 5

# === Node References ===
onready var spawn_timer = $SpawnTimer
onready var buff_container = $BuffContainer
onready var play_area_collision_shape = $CollisionShape2D

# === Internal Buff Tracker ===
var active_buff_nodes = []

func _ready():
	# Safety check: Ensure all scenes are assigned in the Inspector
	if not speed_buff_scene or not regen_buff_scene or not time_buff_scene:
		print_debug("ERROR: BuffSpawner - One or more buff scenes not assigned!")
		if spawn_timer:
			spawn_timer.stop()
		return

	randomize()

	# Spawn initial buffs
	for i in range(initial_buff_count):
		if active_buff_nodes.size() < max_active_buff_limit:
			spawn_random_buff()
		else:
			break

	# Connect the spawn timer signal
	if spawn_timer:
		spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
	else:
		print_debug("ERROR: BuffSpawner - SpawnTimer node not found!")

func _on_SpawnTimer_timeout():
	spawn_buff_if_needed()

func spawn_buff_if_needed():
	# Clean up any freed or invalid buffs from the list
	var valid_buffs = []
	for buff in active_buff_nodes:
		if is_instance_valid(buff):
			valid_buffs.append(buff)
	active_buff_nodes = valid_buffs

	# Spawn a new one if under the limit
	if active_buff_nodes.size() < max_active_buff_limit:
		spawn_random_buff()

func spawn_random_buff():
	# Randomly select one of the buff types to spawn
	var rand_choice = randi() % 3
	var buff_scene_to_spawn = null

	match rand_choice:
		0: buff_scene_to_spawn = speed_buff_scene
		1: buff_scene_to_spawn = regen_buff_scene
		2: buff_scene_to_spawn = time_buff_scene

	if buff_scene_to_spawn:
		var new_buff = buff_scene_to_spawn.instance()

		# Calculate random position inside the rectangular play area
		if not play_area_collision_shape or not play_area_collision_shape.shape is RectangleShape2D:
			print_debug("ERROR: BuffSpawner - Collision shape missing or not a RectangleShape2D!")
			new_buff.global_position = get_viewport_rect().size / 2
		else:
			var shape_node_global_position = play_area_collision_shape.global_position
			var extents = play_area_collision_shape.shape.extents
			var random_x = rand_range(shape_node_global_position.x - extents.x, shape_node_global_position.x + extents.x)
			var random_y = rand_range(shape_node_global_position.y - extents.y, shape_node_global_position.y + extents.y)
			new_buff.global_position = Vector2(random_x, random_y)

		# Add to scene
		if buff_container:
			buff_container.add_child(new_buff)
		else:
			add_child(new_buff)

		# Track the new buff
		active_buff_nodes.append(new_buff)
	else:
		print_debug("ERROR: BuffSpawner - No valid buff scene selected.")
