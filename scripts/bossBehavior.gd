# bossBehavior.gd (attached to Boss Root Area2D node)
extends Area2D

# Movement - base speed set here, states can modify it
export var base_move_speed: float = 50.0 # Default base speed for wandering
var current_move_speed: float = 50.0 # Actual speed used, can be changed by states
var velocity: Vector2 = Vector2.ZERO # Controlled by states

onready var sprite = $Sprite

# Boss's attack initiation area
onready var boss_attack_initiation_area = $DamageArea 
var player_is_in_boss_attack_zone = null

# Boss health and damage cooldown
export var boss_health: int = 3
onready var boss_damage_cooldown_timer = $DamageCooldownTimer
var can_boss_be_damaged: bool = true # Flag for damage cooldown

signal boss_defeated

func _ready():
	current_move_speed = base_move_speed # Initialize current speed

	if boss_attack_initiation_area:
		boss_attack_initiation_area.connect("body_entered", self, "_on_player_entered_boss_attack_zone")
		boss_attack_initiation_area.connect("body_exited", self, "_on_player_exited_boss_attack_zone")
	else:
		print_debug("ERROR (BossBehavior): Boss Attack Initiation Area (e.g., 'DamageArea') node not found!")

	connect("body_entered", self, "_on_boss_bitten_by_player")

	# Connect the boss damage cooldown timer
	if boss_damage_cooldown_timer:
		boss_damage_cooldown_timer.connect("timeout", self, "_on_BossDamageCooldownTimer_timeout")
	else:
		print_debug("ERROR (BossBehavior): BossDamageCooldownTimer node not found! Add it as a child of the Boss.")

# Called by states to set the direction of movement
func set_movement_direction(direction: Vector2):
	if direction.length_squared() > 0: # Only apply velocity if direction is not zero
		self.velocity = direction.normalized() * current_move_speed
	else:
		self.velocity = Vector2.ZERO

# Called by states (like Chase) to modify the effective speed
func set_speed_modifier(multiplier: float):
	current_move_speed = base_move_speed * multiplier

func reset_speed_to_base():
	current_move_speed = base_move_speed

func _physics_process(delta):
	global_position += velocity * delta
	update_visuals() # Call a dedicated method

func update_visuals():
	if not is_instance_valid(sprite):
		return

	# Sprite Flipping
	if velocity.x < -0.1:
		sprite.flip_h = false
	elif velocity.x > 0.1:
		sprite.flip_h = true
	
	# Other visual updates could go here:
	# if is_attacking: sprite.play("attack_animation")
	# else: sprite.play("move_animation")

func _on_player_entered_boss_attack_zone(body: Node):
	if body.is_in_group("player"):
		player_is_in_boss_attack_zone = body

func _on_player_exited_boss_attack_zone(body: Node):
	if body.is_in_group("player") and body == player_is_in_boss_attack_zone:
		player_is_in_boss_attack_zone = null

func perform_boss_attack_on_player():
	if not is_instance_valid(player_is_in_boss_attack_zone):
		return
	print("BOSS PERFORMS ATTACK ON PLAYER: ", player_is_in_boss_attack_zone.name)
	Global.take_player_damage(2)

func _on_boss_bitten_by_player(body: Node):
	if boss_health <= 0 or not can_boss_be_damaged: # Check cooldown
		return

	if body.is_in_group("player") and body.has_method("attempt_damage_entity"):
		body.attempt_damage_entity(self)

func receive_bite_damage(): # Called by Fishda
	if boss_health <= 0 or not can_boss_be_damaged: # Double check cooldown
		return

	boss_health -= 1
	can_boss_be_damaged = false # Start cooldown
	if boss_damage_cooldown_timer:
		boss_damage_cooldown_timer.start()
	else: # Fallback if timer missing, effectively no cooldown (bad)
		can_boss_be_damaged = true
		print_debug("BossBehavior: BossDamageCooldownTimer missing, damage cooldown not activated.")


	print("Boss was bitten! Health: ", boss_health)

	if boss_health <= 0:
		boss_defeated_actions()
	else:
		# Play "boss hit" sound, visual feedback (e.g., flash red)
		# Example: $Sprite.modulate = Color.red
		# yield(get_tree().create_timer(0.2), "timeout") # Simple flash
		# $Sprite.modulate = Color.white
		pass

func _on_BossDamageCooldownTimer_timeout():
	can_boss_be_damaged = true
	print("Boss can be damaged again.")

func boss_defeated_actions():
	# ... (existing defeat logic) ...
	print("BOSS DEFEATED!")
	emit_signal("boss_defeated")
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	if boss_attack_initiation_area:
		boss_attack_initiation_area.monitoring = false
		boss_attack_initiation_area.monitorable = false
	
	self.monitoring = false
	self.monitorable = false

	var state_machine = $StateMachine as StateMachine
	if state_machine:
		if state_machine.states.has("bossdefeated"):
			state_machine.on_child_state_transition("BossDefeated")
		else:
			state_machine.set_process(false)
			state_machine.set_physics_process(false)
			if state_machine.current_state and state_machine.current_state.has_method("exit"):
				state_machine.current_state.exit(self)
			state_machine.current_state = null
	hide()

