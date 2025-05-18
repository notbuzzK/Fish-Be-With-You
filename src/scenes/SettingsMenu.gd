extends Control

func _ready():
	pass # Replace with function body.

# hulaan niyo para san to, gcash sa makaka hula
func _on_FullScreenbutton_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

