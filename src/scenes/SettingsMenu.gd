extends Control

onready var settings_scene = $"."
export var used_in_main_menu: bool = true # flag

func _ready():
	pass # Replace with function body.

# hulaan niyo para san to, gcash sa makaka hula
func _on_FullScreenbutton_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

func _on_Button_pressed():
	if used_in_main_menu:
		get_tree().change_scene("res://src/MainMenu.tscn")
	else:
		settings_scene.visible = false
