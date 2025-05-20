extends Area2D

onready var speed_buff = $CollisionShape2D

func _ready():
	pass

func _on_SpeedBuff_body_entered(body: Node):
	if body.has_method(apply_speed_buff):
		body.apply_speed_buff()
