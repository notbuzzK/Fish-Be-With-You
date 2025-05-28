#Debris.gd
extends Area2D

# Trash Debris Scenes to spawn
export (PackedScene) var trash_1_scene: PackedScene
export (PackedScene) var trash_2_scene: PackedScene
export (PackedScene) var trash_3_scene: PackedScene
export (PackedScene) var trash_4_scene: PackedScene
export (PackedScene) var trash_5_scene: PackedScene
export (PackedScene) var trash_6_scene: PackedScene

# Spawning parameters
export var initial_trash_count: int = 20
export var max_active_trash_limit: int = 30

onready var spawn_timer = $SpawnTimer
onready var trash_container = $TrashContainer 
onready var play_area_collision_shape = $CollisionShape2D

var active_trash_nodes = []

func _ready():
	if not trash_1_scene or not trash_2_scene or not trash_3_scene or not trash_4_scene or not trash_5_scene or not trash_6_scene:
		print_debug("ERROR: PlayArea - One or more trash scenes not assigned in Inspector!")
		if spawn_timer:
			spawn_timer.stop()
		return
	spawn_timer.wait_time = 10.0  #(adjust to your liking)
	spawn_timer.start()

	randomize()

	for i in range(initial_trash_count):
		if active_trash_nodes.size() < max_active_trash_limit:
			spawn_random_trash()
		else:
			break

	if spawn_timer:
		spawn_timer.connect("timeout", self, "_on_SpawnTimer_timeout")
	else:
		print_debug("ERROR: PlayArea - SpawnTimer node not found!")

func _on_SpawnTimer_timeout():
	spawn_trash_if_needed()

func spawn_trash_if_needed():
	var valid_trash = []
	for trash in active_trash_nodes:
		if is_instance_valid(trash):
			valid_trash.append(trash)
	active_trash_nodes = valid_trash

	if active_trash_nodes.size() < max_active_trash_limit:
		spawn_random_trash()

func spawn_random_trash():
	var trash_scene_to_spawn = null
	var rand_choice = randi() % 5

	match rand_choice:
		0: trash_scene_to_spawn = trash_1_scene
		1: trash_scene_to_spawn = trash_2_scene
		2: trash_scene_to_spawn = trash_3_scene
		3: trash_scene_to_spawn = trash_4_scene
		4: trash_scene_to_spawn = trash_5_scene
		5: trash_scene_to_spawn = trash_6_scene
		

	if trash_scene_to_spawn:
		var new_trash = trash_scene_to_spawn.instance()

		if not play_area_collision_shape or not play_area_collision_shape.shape is RectangleShape2D:
			print_debug("ERROR: PlayArea - CollisionShape2D missing or not a RectangleShape2D!")
			new_trash.global_position = get_viewport_rect().size / 2
		else:
			var shape_node_global_position = play_area_collision_shape.global_position
			var extents = play_area_collision_shape.shape.extents
			var random_x = rand_range(shape_node_global_position.x - extents.x, shape_node_global_position.x + extents.x)
			var random_y = rand_range(shape_node_global_position.y - extents.y, shape_node_global_position.y + extents.y)
			new_trash.global_position = Vector2(random_x, random_y)

		if trash_container:
			trash_container.add_child(new_trash)
		else:
			add_child(new_trash)

		active_trash_nodes.append(new_trash)
	else:
		print_debug("ERROR: PlayArea - Could not determine which trash scene to spawn.")
		

func _on_DebrisSpawn_body_entered(body):
	pass # Replace with function body.
