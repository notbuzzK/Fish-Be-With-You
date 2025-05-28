# TimeBuff.gd
extends Area2D

export var time_to_add: float = 10.0  # You can set this in the editor

func _ready():
	connect("body_entered", self, "_on_TimeBuff_body_entered")

func _on_TimeBuff_body_entered(body):
	if body.name == "Fishda":
		print("TIME BOOST APPLIED")
		if body.has_method("add_time"):
			body.add_time(time_to_add)
		queue_free()
		

	
