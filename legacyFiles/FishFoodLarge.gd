extends Area2D

# movement parameters
export var speed: int = 100     
export var move_interval: float = 3.0   
export var stop_threshold: float = 4.0  # snap distance to avoid jitter
export var value: int = 300

# where to go 
var target_position: Vector2
var time_accumulator: float = 0.0

func _ready():
	# randomizes seed and chooses initial target
	randomize()               
	set_random_target()       
	# connect the built‑in signal to our handler
	# to my devs, either remove comment in line below or setup signals in node tab
	# connect("body_entered", self, "_on_FishFood_body_entered")

func _process(delta):
	# picks a random point every [move_interval] seconds
	time_accumulator += delta
	if time_accumulator >= move_interval:
		time_accumulator = 0
		set_random_target()

	# movemet to target and does distance check
	var to_target = target_position - position
	var dist = to_target.length()

	# if distance is farther than threshold, move to target 
	# else snap in place, this avoids jitters
	if dist > stop_threshold:
		var direction = to_target.normalized()
		position += direction * speed * delta
	else:
		position = target_position

# choose a new random spot anywhere in the viewport
func set_random_target():
	var screen_size = get_viewport_rect().size
	target_position = Vector2(
		rand_range(0, screen_size.x),
		rand_range(0, screen_size.y)
	)

# collision function for when Fishda eats FishFood
func _on_FishFoodLarge_body_entered(body):
	if body.name == "Fishda":
		body.ate_fish(value)
		queue_free()

