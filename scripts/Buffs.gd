extends Area2D
class_name Buffs

export (Global.Buff) var buff_category: int = Global.Buff.SPEED

onready var speed_buff = $CollisionShape2D

func _ready():
	connect("body_entered", self, "_on_SpeedBuff_body_entered")  # ensure signal is connected

func _on_SpeedBuff_body_entered(body):  # when fishda collides with the powerup
	if body.name == "Fishda":
		print("SPEEDBOOST")
		if body.has_method("apply_speed_buff"):
			body.apply_speed_buff(2.0, 5.0)  
		queue_free() 
		

