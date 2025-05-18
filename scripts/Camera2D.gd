extends Camera2D

onready var player = get_node("/root/MainMenu/Fishda")

func _process(delta):
	position.x = player.position.x

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
