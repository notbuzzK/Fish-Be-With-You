extends Camera2D

export var target_node_path: NodePath
onready var target: Node2D = get_node_or_null(target_node_path)

func _ready():
	if not target:
		print_debug("Camera ERROR: Target node not found at path: ", target_node_path)
		set_process(false) # Disable processing if no target
	else:
		global_position = target.global_position

func _process(_delta):
	if target:
		global_position = target.global_position
	# else:
		# edge cases i have yet to experience
