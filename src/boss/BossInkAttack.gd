# BossInkAttack.gd
extends State
class_name BossInkAttackState

var owner_boss

# Duration of this state itself (e.g., time for boss to play an animation for the ink attack)
# The ink effect's own duration is separate.
export var ink_attack_state_duration: float = 1.5 
var state_timer: float = 0.0
var ink_fired_this_state: bool = false

func enter(boss_owner_node):
	print_debug("Entering BossInkAttack State")
	self.owner_boss = boss_owner_node
	state_timer = ink_attack_state_duration
	ink_fired_this_state = false

	# Boss might play a specific animation for firing ink
	# owner_boss.play_animation("prepare_ink_attack")
	if owner_boss.has_method("set_movement_direction"):
		owner_boss.set_movement_direction(Vector2.ZERO) # Boss might stop to shoot ink


func exit(boss_owner_node):
	print_debug("Exiting BossInkAttack State")


func update(delta, boss_owner_node):
	state_timer -= delta

	if not ink_fired_this_state and state_timer < ink_attack_state_duration * 0.5: # Fire ink halfway through state, for example
		if owner_boss.has_method("perform_ink_attack"):
			var success = owner_boss.perform_ink_attack()
			if success:
				ink_fired_this_state = true
			else:
				# Ink attack was on cooldown or scene missing, transition out early
				print_debug("BossInkAttackState: perform_ink_attack failed, transitioning out.")
				emit_signal("transitioned", "BossIdle") # Or BossChase
				return


	if state_timer <= 0:
		# Finished ink attack sequence, transition back
		# Decide which state to return to (e.g., Idle or Chase based on player proximity)
		var player_nodes = get_tree().get_nodes_in_group("player")
		if player_nodes.size() > 0:
			var player = player_nodes[0]
			# Assuming Idle state has detection_radius for chase trigger
			var idle_state = owner_boss.get_node("StateMachine/BossIdle") # Adjust path if needed
			if is_instance_valid(idle_state) and owner_boss.global_position.distance_to(player.global_position) < idle_state.detection_radius:
				emit_signal("transitioned", "BossChase")
			else:
				emit_signal("transitioned", "BossIdle")
		else: # No player
			emit_signal("transitioned", "BossIdle")
