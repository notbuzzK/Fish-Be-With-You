# BaseFishFood.gd
extends Area2D
class_name BaseFishFood

export var speed: int = 100
export var move_interval: float = 3.0
export var stop_threshold: float = 4.0
export var value: int = 10
export (Global.FishSize) var fish_food_size_category: int = Global.FishSize.SMOL
export var growth_points: int = 5
export var damage_if_too_small: int = 10

var target_position: Vector2
var time_accumulator: float = 0.0

# Cached reference to the play area bounds
var _play_area_rect: Rect2 

func _ready():
	randomize()
	if not is_connected("body_entered", self, "_on_this_Area2D_body_entered"):
		connect("body_entered", self, "_on_this_Area2D_body_entered")

	# Find and cache the play area boundaries
	# This assumes BaseFishFood is added to a scene that already has a "play_area" group member
	var play_area_nodes = get_tree().get_nodes_in_group("play_area")
	if play_area_nodes.size() > 0:
		var play_area_node = play_area_nodes[0] # Assuming only one
		var collision_shape_node = play_area_node.get_node_or_null("CollisionShape2D") # Use the name of your shape node
		if collision_shape_node and collision_shape_node.shape is RectangleShape2D:
			var extents = collision_shape_node.shape.extents
			# The Rect2 needs a position (top-left corner) and a size (width, height)
			# Global position of the shape node is its center.
			var top_left_x = collision_shape_node.global_position.x - extents.x
			var top_left_y = collision_shape_node.global_position.y - extents.y
			var width = extents.x * 2
			var height = extents.y * 2
			_play_area_rect = Rect2(Vector2(top_left_x, top_left_y), Vector2(width, height))
		else:
			print_debug("WARNING (BaseFishFood): PlayArea CollisionShape2D not found or not a Rectangle. Falling back to viewport.")
			_play_area_rect = get_viewport_rect() # Fallback
	else:
		print_debug("WARNING (BaseFishFood): No node found in group 'play_area'. Falling back to viewport.")
		_play_area_rect = get_viewport_rect() # Fallback

	set_random_target() # Set initial target using the determined bounds

# ... (_physics_process and _on_this_Area2D_body_entered remain the same) ...
func _physics_process(delta):
	time_accumulator += delta
	if time_accumulator >= move_interval:
		time_accumulator = 0.0
		set_random_target()

	var to_target = target_position - global_position
	var dist_sq = to_target.length_squared()

	if dist_sq > stop_threshold * stop_threshold:
		var direction = to_target.normalized()
		global_position += direction * speed * delta
	else:
		global_position = target_position

func _on_this_Area2D_body_entered(body: Node):
	if body.is_in_group("player") and body.has_method("attempt_eat_food"):
		body.attempt_eat_food(self)

# Choose a new random spot strictly within the cached _play_area_rect
func set_random_target():
	if not _play_area_rect: # Should have been set in _ready, but defensive check
		print_debug("ERROR (BaseFishFood): Play area rect not initialized!")
		_play_area_rect = get_viewport_rect() # Emergency fallback

	target_position = Vector2(
		rand_range(_play_area_rect.position.x, _play_area_rect.position.x + _play_area_rect.size.x),
		rand_range(_play_area_rect.position.y, _play_area_rect.position.y + _play_area_rect.size.y)
	)

	# Optional: If fish can somehow get outside the play_area_rect, clamp them back in.
	# This can happen if their speed is very high and they overshoot before the next target is set.
	# global_position.x = clamp(global_position.x, _play_area_rect.position.x, _play_area_rect.end.x)
	# global_position.y = clamp(global_position.y, _play_area_rect.position.y, _play_area_rect.end.y)
