# bossIdle.gd
extends State
class_name BossIdleState

var owner_boss
var player_node # Cache player reference if found

# export var move_speed: float = 50.0 # Speed is now managed by owner_boss.base_move_speed
export var min_wander_time: float = 1.5
export var max_wander_time: float = 4.0
export var detection_radius: float = 300.0

var move_direction: Vector2 = Vector2.ZERO
var current_wander_timer: float = 0.0

func randomize_wander_params():
	move_direction = Vector2(rand_range(-1, 5), rand_range(-1, 1)).normalized()
	current_wander_timer = rand_range(min_wander_time, max_wander_time)

func enter(boss_owner_node):
#	print("Entering BossIdle State")
	self.owner_boss = boss_owner_node
	if owner_boss and owner_boss.has_method("reset_speed_to_base"):
		owner_boss.reset_speed_to_base() # Use base speed for wandering
	randomize_wander_params()
	player_node = null

func exit(boss_owner_node):
#	print("Exiting BossIdle State")
	if owner_boss and owner_boss.has_method("set_movement_direction"):
		owner_boss.set_movement_direction(Vector2.ZERO) # Stop movement

func update(delta, boss_owner_node):
	if current_wander_timer > 0:
		current_wander_timer -= delta
	else:
		randomize_wander_params()

	if not is_instance_valid(player_node):
		var players_in_scene = get_tree().get_nodes_in_group("player")
		if players_in_scene.size() > 0:
			player_node = players_in_scene[0]

	if is_instance_valid(player_node) and is_instance_valid(owner_boss):
		if owner_boss.global_position.distance_to(player_node.global_position) < detection_radius:
			emit_signal("transitioned", "BossChase")
			return

func physics_update(delta, boss_owner_node):
	if owner_boss and owner_boss.has_method("set_movement_direction"):
		owner_boss.set_movement_direction(move_direction)
