# PauseMenu.gd
extends Control

onready var settings_scene = $Settings


func _ready():
	visible = false # Start hidden
	# $AnimationPlayer.play("RESET") # You might not need RESET if it starts hidden
	# get_tree().paused = false # Game shouldn't start paused by the pause menu

func _unhandled_input(event): # Use _unhandled_input for global key presses like Esc
	if event.is_action_pressed("esc"):
		# Do NOT open pause menu if level is complete
		if Global.is_level_complete:
			get_tree().set_input_as_handled() # Consume the event so other things don't process esc
			return

		if get_tree().paused and visible: # If game is paused AND pause menu is visible
			$AnimationPlayer.play_backwards("blur")
			resume_game()
		elif not get_tree().paused: # If game is not paused
			$AnimationPlayer.play("blur")
			pause_game()
		get_tree().set_input_as_handled()


func resume_game():
	get_tree().paused = false
	# $AnimationPlayer.play_backwards("blur") # Play animation if you have one
	visible = false # Hide the pause menu

func pause_game():
	# Again, double check, though _unhandled_input should cover it
	if Global.is_level_complete:
		return

	get_tree().paused = true
	# $AnimationPlayer.play("blur") # Play animation
	visible = true   # Show the pause menu

func _on_Resume_pressed():
	resume_game()

func _on_Restart_pressed():
	# Make sure to reset global states if restarting
	#Global.reset_score() # This also sets is_level_complete to false
	Global.reset_score()
	Global.reset_player_stats()
	get_tree().paused = false # Unpause before reloading
	get_tree().reload_current_scene()

func _on_Settings_pressed():
	print("Settings button pressed (from Pause Menu)")
	settings_scene.visible = true
	

func _on_Quit_pressed():
	#Global.reset_score() # Good practice
	Global.reset_score()
	Global.reset_player_stats()
	get_tree().paused = false # Unpause before changing scene
	get_tree().change_scene("res://src/MainMenu.tscn")

# Remove testEsc() and the _process function if you move Esc handling to _unhandled_input
# func _process(_delta):
# 	testEsc()



func _on_Pause_Menu_button_pressed():
	if Global.is_level_complete:
		Global.reset_score()
		get_tree().set_input_as_handled()
		return  # Only return early if level is complete
		

	# If the game is already paused and pause menu is visible
	if get_tree().paused and visible:
		$AnimationPlayer.play_backwards("blur")
		resume_game()
	elif not get_tree().paused:
		$AnimationPlayer.play("blur")
		pause_game()

	get_tree().set_input_as_handled()
	
