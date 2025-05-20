# BossChase.gd
extends State
class_name BossChaseState

var owner_boss
var player_node

export var chase_speed: float = 80.0
export var give_up_chase_distance: float = 450.0

func enter(boss_owner_node):
#	print("Entering BossChase State")
	self.owner_boss = boss_owner_node
	var players_in_scene = get_tree().get_nodes_in_group("player")
	if players_in_scene.size() > 0:
		player_node = players_in_scene[0]
	else:
		player_node = null

func exit(boss_owner_node):
#	print("Exiting BossChase State")
	if owner_boss and owner_boss.has_method("set_velocity"):
		owner_boss.set_velocity(Vector2.ZERO)

func update(delta, boss_owner_node):
	if not is_instance_valid(player_node):
		var players_in_scene = get_tree().get_nodes_in_group("player")
		if players_in_scene.size() > 0:
			player_node = players_in_scene[0]
		else:
			emit_signal("transitioned", "BossIdle")
			return

	if owner_boss.global_position.distance_to(player_node.global_position) > give_up_chase_distance:
		emit_signal("transitioned", "BossIdle")
		return

	# --- Transition Logic: Chase -> Attack ---
	# Check the variable set by bossBehavior.gd when player enters the boss's attack initiation zone
	if owner_boss and owner_boss.player_is_in_boss_attack_zone: # CHECKING THE CORRECT VARIABLE
		emit_signal("transitioned", "BossAttack")
		return

func physics_update(delta, boss_owner_node):
	# ... (physics update logic remains the same) ...
	if not is_instance_valid(player_node) or not is_instance_valid(owner_boss):
		if owner_boss and owner_boss.has_method("set_velocity"):
			owner_boss.set_velocity(Vector2.ZERO)
		return

	var direction_to_player = (player_node.global_position - owner_boss.global_position).normalized()
	
	if owner_boss.has_method("set_velocity"):
		owner_boss.set_velocity(direction_to_player * chase_speed)
	elif owner_boss:
		owner_boss.global_position += direction_to_player * chase_speed * delta
