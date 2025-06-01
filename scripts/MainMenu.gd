extends Node2D

var nextScene = Global.load_player_progress()


func _ready():
	pass # Replace with function body.

func _on_NewGame_pressed():
	get_tree().change_scene("res://src/levels/Level1.tscn")
	print("New Game pressed: going to tutorial") #new game dapat pupunta ng tutorial?

func _on_LoadGame_pressed():
	get_tree().change_scene(nextScene)

func _on_ChangeAppearance_pressed():
	get_tree().change_scene("res://src/scenes/ChangeAppearance.tscn")

func _on_Settings_pressed():
	get_tree().change_scene("res://src/scenes/Settings.tscn")


func _on_PearlButton1_pressed():
	get_tree().change_scene("res://src/levels/Level1.tscn")
	print("New Game pressed: going to level 1")


func _on_PearlButton2_pressed():
	get_tree().change_scene(nextScene)


func _on_PearlButton3_pressed():
	get_tree().change_scene("res://src/scenes/ChangeAppearance.tscn")


func _on_tutorial_pressed():
	get_tree().change_scene("res://src/components/how2play.tscn")
