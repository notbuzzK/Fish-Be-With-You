# jigglePhysx.gd
extends Node2D

export var jiggle_amplitude: float = 5.0
export var jiggle_speed: float = 3.0

var start_pos = Vector2()
var t = 0.0

func _ready():
	start_pos = position

func _process(delta):
	t += delta
	position.y = start_pos.y + sin(t * jiggle_speed) * jiggle_amplitude
