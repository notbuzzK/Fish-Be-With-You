extends Area2D
class_name buffs

export (Global.Buff) var buff_category: int = Global.Buff.SPEED

onready var speed_buff = $CollisionShape2D

func _ready():
	pass

func _on_SpeedBuff_body_entered(body):
	pass # Replace with function body.
