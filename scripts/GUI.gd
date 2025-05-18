# GUI.gd
extends Control

onready var progressBar = $ProgressBar
onready var score_label = $ScoreLabel
onready var star2 = $Star2
onready var star3 = $Star3
onready var star4 = $Star4
onready var level_complete_menu = $LevelComplete
onready var health_bar = $HealthBar
onready var game_over_menu = $GameOver 

export var score_to_complete_level: int = 100

func _ready():
	Global.connect("score_updated", self, "_on_Global_score_updated")
	progressBar.max_value = score_to_complete_level
	_on_Global_score_updated(Global.get_score())
	level_complete_menu.visible = false
	update_stars(Global.get_score())
	Global.connect("player_health_updated", self, "_on_player_health_updated")
	Global.connect("player_died", self, "_on_Global_player_died") # Connect to player_died
	
	if health_bar:
		health_bar.max_value = Global.PLAYER_MAX_HEALTH
		health_bar.value = Global.player_current_health # Initialize
	
	if game_over_menu:
		game_over_menu.visible = false # Hide initially

func _on_player_health_updated(new_health: int):
	if health_bar:
		health_bar.value = new_health
	print("GUI: Player health updated to ", new_health)

func _on_Global_player_died(): # Connected to Global.player_died
	print("GUI: Received player_died signal. Showing game over.")
	show_game_over_menu()

func show_game_over_menu():
	if game_over_menu:
		game_over_menu.visible = true
	# Ensure other menus are not conflicting
	if level_complete_menu:
		level_complete_menu.visible = false # Hide level complete if it was somehow visible
	# Pause game if not already (player death might pause it too)
	if not get_tree().paused:
		get_tree().paused = true
	# You might want to set a Global.is_game_over = true flag
	# to prevent pause menu from opening, similar to is_level_complete

func _on_Global_score_updated(new_score: int):
	if score_label:
		score_label.text = "Score: " + str(new_score)
	progressBar.value = new_score
	update_stars(new_score)

	if new_score >= score_to_complete_level:
		if not get_tree().paused and not Global.is_level_complete: # Check Global flag
			show_level_complete()

func update_stars(current_score: int):
	var score_percent = 0
	if score_to_complete_level > 0:
		score_percent = (float(current_score) / score_to_complete_level) * 100
	star2.modulate = Color.black
	star3.modulate = Color.black
	star4.modulate = Color.black
	if score_percent >= 33:
		star2.modulate = Color.yellow
	if score_percent >= 66:
		star3.modulate = Color.yellow
	if score_percent >= 100:
		star4.modulate = Color.yellow

func show_level_complete():
	Global.set_level_complete_status(true) # Set the global flag
	level_complete_menu.visible = true
	get_tree().paused = true
	print("Level Complete!")

# Call this when transitioning away from the level complete screen (e.g., "Next Level" button)
func hide_level_complete_and_unpause():
	Global.set_level_complete_status(false)
	level_complete_menu.visible = false
	# Only unpause if the pause menu ISN'T also trying to keep it paused
	if get_tree().paused: # Only unpause if it was paused by level complete
		get_tree().paused = false

func _on_Restart_pressed():
#	print("DEBUG: _on_RetryLevelButton_pressed CALLED")
	Global.set_level_complete_status(false) # Reset flag
	get_tree().paused = false
	Global.reset_score()
	Global.reset_player_stats()
	print("restart button pressed")
	get_tree().reload_current_scene()

func _on_Continue_pressed():
#	print("DEBUG: _on_NextLevelButton_pressed CALLED")
	Global.set_level_complete_status(false) 
	get_tree().paused = false
	Global.reset_score() 
	Global.reset_player_stats()
	print("Next Level button pressed")
	get_tree().change_scene("res://src/levels/Level2.tscn")

func _on_MainMenu_pressed():
#	print("DEBUG: _on_LC_MainMenuButton_pressed CALLED")
	Global.set_level_complete_status(false)
	get_tree().paused = false
	Global.reset_score()
	Global.reset_player_stats()
	print("mainmenu button pressed")
	get_tree().change_scene("res://src/MainMenu.tscn")
