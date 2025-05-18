extends Area2D
class_name BaseFishFood

# ALL EXPORTED VARS GO TO INSPECTOR PANEL TO CHANGE VALUES

# movement params
export var speed: int = 100
export var move_interval: float = 3.0
export var stop_threshold: float = 4.0 # snap distance to avoid jitter

export var value: int = 10 # fish value


export (Global.FishSize) var fish_food_size_category: int = Global.FishSize.SMOL # fish classification
export var growth_points: int = 5   # how much it contributes to player growth
export var damage_if_too_small: int = 10 # damage dealt to player if player is too small


# Internal state
var target_position: Vector2
var time_accumulator: float = 0.0

func _ready():
	randomize()
	set_random_target()
	# since we use same script for 3 fishes, we need to use this
	# so that we dont have to worry about setting signal for each fish
	if not is_connected("body_entered", self, "_on_this_Area2D_body_entered"):
		connect("body_entered", self, "_on_this_Area2D_body_entered")

func _physics_process(delta):
	# Picks a random point every [move_interval] seconds
	time_accumulator += delta
	if time_accumulator >= move_interval:
		time_accumulator = 0.0 # Reset accumulator
		set_random_target()

	# Movement to target and distance check
	var to_target = target_position - global_position
	var dist_sq = to_target.length_squared()

	# If distance is farther than threshold, move to target
	# Else snap in place, this avoids jitters
	if dist_sq > stop_threshold * stop_threshold: # Compare distances
		var direction = to_target.normalized()
		global_position += direction * speed * delta
	else:
		global_position = target_position

# Choose a new random spot anywhere in the viewport
func set_random_target():
	var screen_size = get_viewport_rect().size
	target_position = Vector2(
		rand_range(0, screen_size.x),
		rand_range(0, screen_size.y)
	)


# player eat fish method
func _on_this_Area2D_body_entered(body: Node):
	if body.is_in_group("player") and body.has_method("attempt_eat_food"):
		body.attempt_eat_food(self)
