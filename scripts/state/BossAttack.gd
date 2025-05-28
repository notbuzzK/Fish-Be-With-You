# BossAttack.gd
extends State
class_name BossAttackState

var owner_boss
var player_target

export var attack_wind_up_duration: float = 0.5 # Time before the actual damage/effect happens
export var attack_active_duration: float = 0.3 # How long the "hitbox" or damage effect is active
export var attack_cooldown: float = 2.0     # Time AFTER an attack before another can START

enum InkAttack { WINDUP, ACTIVE, COOLDOWN }
enum AttackPhase { WINDUP, ACTIVE, COOLDOWN }
var current_phase: int = AttackPhase.WINDUP
var phase_timer: float = 0.0

func enter(boss_owner_node):
#	print("Entering BossAttack State - Windup")
	var which_attack_to_use = randf()
	print("attack number: ", which_attack_to_use)

	if which_attack_to_use >= 0.51:
		current_phase = AttackPhase.WINDUP
		print("Attack Phase Windup")
	else:
		current_phase = InkAttack.WINDUP
		print("Ink Attack Phase Windup")
	
	self.owner_boss = boss_owner_node
	self.player_target = owner_boss.player_is_in_boss_attack_zone # Get player target from boss behavior

	phase_timer = attack_wind_up_duration
	
	if owner_boss.has_method("set_movement_direction"):
		owner_boss.set_movement_direction(Vector2.ZERO) # Stop movement during attack sequence
	
	# Trigger "start attack windup" animation/sound on owner_boss if you have one
	# owner_boss.play_animation("attack_windup")

func exit(boss_owner_node):
	pass
#	print("Exiting BossAttack State")
	# Reset any attack animations or visual effects if necessary
	# owner_boss.play_animation("idle_or_chase_after_attack")

func update(delta, boss_owner_node):
	# Constant check: If player target becomes invalid or leaves the boss's attack zone, transition out
	if not is_instance_valid(player_target) or not owner_boss.player_is_in_boss_attack_zone:
		emit_signal("transitioned", "BossChase") # Or "BossIdle" if player is completely gone
		return

	phase_timer -= delta

	if phase_timer <= 0:
		match current_phase:
			AttackPhase.WINDUP:
#				print_debug("BossAttack: Windup complete. Entering ACTIVE phase.")
				current_phase = AttackPhase.ACTIVE
				phase_timer = attack_active_duration
				# Actually perform the attack action (damage, create hitbox, etc.)
				if owner_boss.has_method("perform_boss_attack_on_player"):
					owner_boss.perform_boss_attack_on_player() 
				# Trigger "active attack" animation/sound

			AttackPhase.ACTIVE:
#				print_debug("BossAttack: Active phase complete. Entering COOLDOWN phase.")
				current_phase = AttackPhase.COOLDOWN
				phase_timer = attack_cooldown
				# Clean up attack hitboxes if they were temporary, trigger "attack end" animation

			AttackPhase.COOLDOWN:
#				print_debug("BossAttack: Cooldown complete. Transitioning back to Chase.")
				# Cooldown finished, decide what to do next (usually go back to chasing)
				emit_signal("transitioned", "BossChase")
				# No need to return here as the transition will handle it

			InkAttack.WINDUP:
				print("some logic here for windup")
				current_phase = InkAttack.ACTIVE

			InkAttack.ACTIVE:
				print("some logic here for active")
				current_phase = InkAttack.COOLDOWN
				phase_timer = attack_cooldown

			InkAttack.COOLDOWN:
				emit_signal("transitioned", "BossChase")
