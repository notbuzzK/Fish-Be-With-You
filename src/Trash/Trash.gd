# Trash.gd
extends Area2D

func _ready():
	connect("body_entered", self, "_on_Trash_body_entered")

func _on_Trash_body_entered(body):
	if body.name == "Fishda":
		print("Fishda hit trash!")
		if body.has_method("on_hit_trash"):
			body.on_hit_trash(self)
		queue_free()
