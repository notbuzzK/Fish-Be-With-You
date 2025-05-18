extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_this_Area2D_body_entered")

func _on_this_Area2D_body_entered(body):
	if body.is_in_group("player"):
		print("boss hit player")
