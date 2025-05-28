extends Control


onready var settings_scene = $"." # This line is not used; consider removing or assigning the actual settings scene
export var used_in_main_menu: bool = true

func _ready():
	pass


	

func _on_button_pressed():
	if used_in_main_menu:
		get_tree().change_scene("res://src/MainMenu.tscn")
	else:
		settings_scene.visible = true

