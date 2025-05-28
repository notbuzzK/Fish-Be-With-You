# BossChase.gd
extends State
class_name BossChaseState

var owner_boss
var player_node

export var chase_speed: float = 80.0
export var give_up_chase_distance: float = 450.0

export var chance_to_ink_while_chasing: float = 0.05 # Lower chance while actively chasing
var time_since_last_ink_check: float = 0.0

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
	# --- Ink Attack Check ---
	time_since_last_ink_check += delta
	if time_since_last_ink_check >= 1.0: 
		time_since_last_ink_check = 0.0
		# Check the boss's own cooldown flag
		if owner_boss and owner_boss.can_use_ink_attack: # Accessing var from bossBehavior.gd
			if randf() < chance_to_ink_while_chasing:
				print_debug(self.name + ": Telling boss to perform ink attack action.")
				if owner_boss.has_method("perform_ink_attack_action"):
					owner_boss.perform_ink_attack_action() 
					# The boss STAYS in this Idle/Chase state. Its movement continues.
					# The boss might play a quick "firing" animation here.
	
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
