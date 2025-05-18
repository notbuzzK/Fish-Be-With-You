# Fishda.gd
extends KinematicBody2D

# ALL "GLOBAL" CODE CHECK GLOBAL.GD SCRIPT
# global.gd is literally a global script used for state management across different files

# Player Size & Growth
var current_size_points: int = 0
var current_visual_scale: float = 1.0 
const MIN_VISUAL_SCALE: float = 0.5 
const MAX_VISUAL_SCALE: float = 5.0 # Example max visual size
const SCALE_FACTOR_PER_GROWTH_POINT: float = 0.02 # How much 1 growth point affects visual scale

# Damage Cooldown
var can_take_eat_attempt_damage: bool = true # Flag to control damage taking

# movement params
export var base_speed: int = 200
export var acceleration: float = 9.8 # not used, debating to use it or not

var current_speed_multiplier: float = 1.0
var velocity: Vector2 = Vector2()

onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D
onready var speed_buff_timer = $Timer
onready var damage_cooldown_timer = $DamageCooldownTimer

func _ready():
	reset_player_state()
	Global.connect("player_died", self, "_on_player_died")
	# Connect the damage cooldown timer's timeout signal
	if damage_cooldown_timer:
		if not damage_cooldown_timer.is_connected("timeout", self, "_on_DamageCooldownTimer_timeout"): # Prevent multiple connections
			damage_cooldown_timer.connect("timeout", self, "_on_DamageCooldownTimer_timeout")
	else:
		print_debug("ERROR: DamageCooldownTimer node not found on Fishda!")

# self explanatory
func reset_player_state():
	current_size_points = 0
	current_visual_scale = 1.0
	update_visual_size()
	can_take_eat_attempt_damage = true # Reset damage cooldown flag
	if damage_cooldown_timer and not damage_cooldown_timer.is_stopped(): # Check if timer exists and is running
		damage_cooldown_timer.stop() # Stop timer if it was running from a previous state


func _physics_process(_delta):
	var actual_speed = base_speed * current_speed_multiplier
	velocity = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		velocity.x -= actual_speed
	if Input.is_action_pressed("move_right"):
		velocity.x += actual_speed
	if Input.is_action_pressed("move_up"):
		velocity.y -= actual_speed
	if Input.is_action_pressed("move_down"):
		velocity.y += actual_speed

	move_and_slide(velocity)

	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true

# function for player growth
# when called, will multiply accepted amount to scale factor growth
# which in turn will make player visually grow
func grow(amount: int):
	current_size_points += amount
	current_visual_scale = 1.0 + (current_size_points * SCALE_FACTOR_PER_GROWTH_POINT)
	current_visual_scale = clamp(current_visual_scale, MIN_VISUAL_SCALE, MAX_VISUAL_SCALE)
	update_visual_size()

# helper function
func update_visual_size():
	if sprite:
		sprite.scale = Vector2(current_visual_scale, current_visual_scale)
	if collision_shape:
		collision_shape.scale = Vector2(current_visual_scale, current_visual_scale)
	print("Player visual scale updated to: ", current_visual_scale)

# moved to separate function for ease of use
func _on_player_died():
	print("FISHDA DIED! Game Over.")
	set_physics_process(false)
	hide()
	if not get_tree().paused:
		get_tree().paused = true

# Function for eating fish food 
func attempt_eat_food(food_item: BaseFishFood):
	var can_eat = false
	
	# similar to switch case
	# player needs to grow first before being able to eat meidum and large fish
	match food_item.fish_food_size_category:
		Global.FishSize.SMOL:
			can_eat = true # Player can always eat smol food
		Global.FishSize.MEDIUM:
			if current_size_points >= Global.CAN_EAT_MEDIUM_THRESHOLD:
				can_eat = true
		Global.FishSize.LARGE:
			if current_size_points >= Global.CAN_EAT_LARGE_THRESHOLD:
				can_eat = true
		# Global.FishSize.BOSS: # Example for future
			# if current_size_points >= CAN_EAT_BOSS_THRESHOLD:
			# 	can_eat = true


	if can_eat: # Successfully ate food
		Global.add_score(food_item.value)
		grow(food_item.growth_points)
		# wag niyo na intindihin tong nasa baba basta for logging lang to hahahaha
		print("Fishda ate %s food. Score: %s, Size Points: %s" % [Global.FishSize.keys()[food_item.fish_food_size_category], Global.get_score(), current_size_points])
		food_item.queue_free() # Remove the food item
		
		# Play eating sound effect
	else: # Player CANNOT eat this food item
		# Tried to eat something too big
		if can_take_eat_attempt_damage: # Check if player can currently take this type of damage
			Global.take_player_damage(food_item.damage_if_too_small)
			print("Fishda tried to eat %s food but was too small! Took %s damage." % [Global.FishSize.keys()[food_item.fish_food_size_category], food_item.damage_if_too_small])
			
			can_take_eat_attempt_damage = false # Prevent further damage immediately
			if damage_cooldown_timer:
				damage_cooldown_timer.start() # Start the 2-second cooldown
			
			# Play "ouch" sound effect, maybe a small knockback or visual feedback
		else:
			print("Fishda bumped into %s food but is currently immune to eating damage." % Global.FishSize.keys()[food_item.fish_food_size_category])
			# can add some visual queues here too

# This function is called when the DamageCooldownTimer times out
func _on_DamageCooldownTimer_timeout():
	can_take_eat_attempt_damage = true # Player can take damage from eating attempts again
	print("Damage cooldown expired. Fishda can take eating damage again.")

# speed buff logic
func apply_speed_buff(multiplier: float, duration: float):
	print("Speed buff applied! Multiplier:", multiplier, "Duration:", duration)
	current_speed_multiplier = multiplier
	if speed_buff_timer:
		speed_buff_timer.wait_time = duration
		speed_buff_timer.start()
	sprite.modulate = Color.aqua

# IMPORTANT:
# dito niyo ilalagay yung logic for debuffs (
# yung timer and +time buff sa Global.gd ilalaga yun

func _on_Timer_timeout(): # This function name MUST match the signal connection for the speed_buff_timer
	print("Speed buff expired.")
	current_speed_multiplier = 1.0
	sprite.modulate = Color.white

# for testing purposes, press spacebar to manually enable speed buff
func _input(event):
	if event.is_action_pressed("ui_accept"):
		apply_speed_buff(2.0, 5.0)
