# GUI.gd
extends Control

# node reference
onready var progressBar = $ProgressBar
onready var score_label = $ScoreLabel
onready var s1 = $Stars/Star1
onready var s2 = $Stars/Star2
onready var s3 = $Stars/Star3
onready var level_complete_menu = $LevelComplete
onready var health_bar = $HealthBar
onready var game_over_menu = $GameOver
onready var level_timer_node = $LevelTimer # Renamed for clarity, reference to Timer node
onready var time_left_label = $TimeLeft # Renamed for clarity, reference to Label node

# stars for level complete menu
onready var s4 = $LevelComplete/PanelContainer/VBoxContainer/PanelContainer/Star1
onready var s5 = $LevelComplete/PanelContainer/VBoxContainer/PanelContainer/Star2
onready var s6 = $LevelComplete/PanelContainer/VBoxContainer/PanelContainer/Star3

# placeholder for hearts
onready var heart1 = $Hearts/Heart1
onready var heart2 = $Hearts/Star5
onready var heart3 = $Hearts/Star6

#Level label
onready var level_label = $LevelLabel


export var score_to_complete_level: int = 100

# Time thresholds for LOSING stars (based on ELAPSED time)
const LOSE_3RD_STAR_AFTER: float = 30.0  # After 30s, can only get max 2 stars
const LOSE_2ND_STAR_AFTER: float = 60.0  # After 60s, can only get max 1 star
const LOSE_1ST_STAR_AFTER: float = 90.0  # After 90s, can only get max 0 stars (level fail if not complete)
# Level fails if time to complete is > TIME_FOR_1_STAR or if level_timer_node times out before score is met.

# This variable will store the number of stars earned when the level is completed
var current_potential_stars: int = 3 # Start with the potential for 3 stars
var stars_earned_this_level: int = 0 # Final stars when level is completed

func _ready():
	Global.connect("time_added", self, "_on_Global_time_added")
	Global.connect("score_updated", self, "_on_Global_score_updated")
	progressBar.max_value = score_to_complete_level
	_on_Global_score_updated(Global.get_score())
	level_complete_menu.visible = false
#	update_stars(Global.get_score()
#	update_stars(Global.get_score(), minutes, seconds)
	Global.connect("player_health_updated", self, "_on_player_health_updated")
	Global.connect("player_died", self, "_on_Global_player_died") # Connect to player_died
	
	if health_bar:
		health_bar.max_value = Global.PLAYER_MAX_HEALTH
		health_bar.value = Global.player_current_health # Initialize
	
	if game_over_menu:
		game_over_menu.visible = false # Hide initially
	
		# Connect LevelTimer's timeout signal (when time runs out)
	if level_timer_node:
		level_timer_node.connect("timeout", self, "_on_LevelTimer_timeout")
	
	current_potential_stars = 3 # Reset at level start
	stars_earned_this_level = 0 # Reset at level start
	update_ingame_star_display(current_potential_stars) # Initial display of 3 stars
	update_time_display()
	
	heart1.modulate = Color.red
	heart2.modulate = Color.red
	heart3.modulate = Color.red
	
	

# Called every frame
func _process(_delta):
	update_time_display()
	
	# Only update potential stars if the level is not yet complete and game not paused by a menu
	if not Global.is_level_complete and (not get_tree().paused or level_complete_menu.visible or game_over_menu.visible): # Allow update if menus are up for final display
		if level_timer_node:
			var total_level_time = level_timer_node.wait_time
			var time_remaining = level_timer_node.time_left
			
			if time_remaining <= 0 and total_level_time > 0: # Timer has run out (or just about to)
				time_remaining = 0.00001 # Avoid division by zero if used elsewhere, ensure elapsed is full

			var time_elapsed = total_level_time - time_remaining
			
			var new_potential_stars = 3 # Assume 3 stars initially
			if time_elapsed > LOSE_3RD_STAR_AFTER: # Check from highest threshold down
				new_potential_stars = 2
			if time_elapsed > LOSE_2ND_STAR_AFTER:
				new_potential_stars = 1
			if time_elapsed > LOSE_1ST_STAR_AFTER:
				new_potential_stars = 0
			
			if new_potential_stars != current_potential_stars:
				current_potential_stars = new_potential_stars
			update_ingame_star_display(current_potential_stars)

func update_time_display():
	if level_timer_node and time_left_label:
		var time_remaining_seconds = level_timer_node.time_left
		
		# Format the time as MM:SS
		var minutes = floor(time_remaining_seconds / 60)
		var seconds = int(time_remaining_seconds) % 60 # Use int() for whole seconds
		
		# Format with leading zeros for seconds
		time_left_label.text = "Time: %02d:%02d" % [minutes, seconds]
		# Or just raw seconds:
		# time_left_label.text = "Time Left: " + str(snapped(time_remaining_seconds, 0.1)) # Snapped to 1 decimal

# This function updates the main gameplay star display
func update_ingame_star_display(stars_to_show: int):
	# Assuming star1_node, star2_node, star3_node are the main UI stars visible during gameplay
	if not is_instance_valid(s1) or not is_instance_valid(s2) or not is_instance_valid(s3):
		print_debug("WARNING (GUI): In-game star nodes (Star1, Star2, Star3) not found for display.")
		return

	# print_debug("Updating in-game stars to show: ", stars_to_show) # Can be noisy
	s1.modulate = Color.black
	s2.modulate = Color.black
	s3.modulate = Color.black

	if stars_to_show >= 1: # If 1 star or more, light up the first one (e.g. $Star3 if your nodes are ordered 3,2,1)
		s1.modulate = Color.yellow
		s4.modulate = Color.yellow
	if stars_to_show >= 2:
		s2.modulate = Color.yellow
		s5.modulate = Color.yellow
	if stars_to_show >= 3:
		s3.modulate = Color.yellow 
		s6.modulate = Color.yellow

func _on_player_health_updated(new_health: int):
	if health_bar:
		health_bar.value = new_health
	print("GUI: Player health updated to ", new_health)
	
	# Reset all hearts to black first
	heart1.modulate = Color.black
	heart2.modulate = Color.black
	heart3.modulate = Color.black

	# Turn hearts red based on current health
	if new_health >= 1:
		heart1.modulate = Color.red
	if new_health >= 2:
		heart2.modulate = Color.red
	if new_health >= 3:
		heart3.modulate = Color.red

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

# This function is called when the SCORE target is met
func _on_Global_score_updated(new_score: int):
	if score_label:
		score_label.text = "Score: " + str(new_score)
	
	# Update progress bar (if still used for score visually)
	if progressBar: # Check if progressBar exists
		progressBar.value = new_score

	# Check for level completion based on score
	if new_score >= score_to_complete_level:
		# Level complete based on score, now check time for stars
		if not get_tree().paused and not Global.is_level_complete:
			# Level is complete by score. The current_potential_stars IS the stars_earned_this_level.
			stars_earned_this_level = current_potential_stars 
			
			if stars_earned_this_level == 0:
				print("Player completed level but was too slow for any stars. Level Failed (by time criteria).")
				# update_star_visuals_on_menu(game_over_menu, 0) # Show 0 stars on fail menu
				# show_game_over_menu() # Or a specific "Level Failed - Too Slow"
				# For now, let's allow 0-star completion if score is met
				show_level_complete() # This will display 0 stars on the complete menu
			else:
				show_level_complete() # This will display earned stars on the complete menu
			show_level_complete() # Show the level complete menu (which will display the stars)
	# else:
		# If you had old star update logic here based on score progression, remove or adapt it.
		# update_stars_based_on_score_progression(new_score) # Example old call

# old method, for reference onnly
#func update_stars(current_score: int):

#func update_stars(current_score: int, minutes: float, seconds: int):
#	# old setup
##	var score_percent = 0
##	if score_to_complete_level > 0:
##		score_percent = (float(current_score) / score_to_complete_level) * 100
##	star2.modulate = Color.black
##	star3.modulate = Color.black
##	star4.modulate = Color.black
##	if score_percent >= 33:
##		star2.modulate = Color.yellow
##	if score_percent >= 66:
##		star3.modulate = Color.yellow
##	if score_percent >= 100:
##		star4.modulate = Color.yellow

# This function is called when the level timer runs out
func _on_LevelTimer_timeout():
	print("Level Time is UP!")
	if not Global.is_level_complete and (not is_instance_valid(game_over_menu) or not game_over_menu.visible):
		stars_earned_this_level = 0 # Failed to complete score in time
		current_potential_stars = 0 # No more potential
		print("Time up and score not met. Level Failed.")
		update_ingame_star_display(0) # Make sure in-game UI shows 0 stars
		update_star_visuals_on_menu(game_over_menu, 0) # Show 0 stars on fail menu
		show_game_over_menu()
		if not get_tree().paused:
			get_tree().paused = true

#func calculate_and_set_stars(time_elapsed: float):
#	print_debug("Calculating stars. Time elapsed: %.2f seconds" % time_elapsed)
#	if time_elapsed <= TIME_FOR_3_STARS:
#		stars_earned_this_level = 3
#	elif time_elapsed <= TIME_FOR_2_STARS:
#		stars_earned_this_level = 2
#	elif time_elapsed <= TIME_FOR_1_STAR:
#		stars_earned_this_level = 1
#	else:
#		stars_earned_this_level = 0 # Failed to get even 1 star based on time
#		print("Player completed level but was too slow for any stars.")
#		# Depending on game design, this could still be a "level complete" but with 0 stars,
#		# or it could be a "level failed" if meeting TIME_FOR_1_STAR is mandatory.
#		# For now, we assume it's 0 stars but level is still complete because score was met.


# This function is called when the level is successfully completed by score
func show_level_complete():
	Global.set_level_complete_status(true) # flag

	if level_timer_node:
		level_timer_node.stop()

	# stars_earned_this_level should have been set in _on_Global_score_updated
	update_star_visuals_on_menu(level_complete_menu, stars_earned_this_level)

	level_complete_menu.visible = true
	if not get_tree().paused: # Ensure pausing only if not already paused by game over for other reasons
		get_tree().paused = true
		print("Level Complete! Stars earned: ", stars_earned_this_level)


# Generic function to update star visuals on a given menu panel (level complete, game over)
# This remains the same as before.
func update_star_visuals_on_menu(menu_node_panel, stars_count: int):
	if not is_instance_valid(menu_node_panel):
		return

	if not s1 or not s2 or not s3:
		print_debug("WARNING (GUI): Star nodes (Star1, Star2, Star3) not found as children of menu: ", menu_node_panel.name)
		return

	s1.modulate = Color.black 
	s2.modulate = Color.black
	s3.modulate = Color.black

	# Adjust this logic based on how your stars are visually ordered (e.g., left-to-right)
	# Assuming Star1 is for 3 stars, Star2 for 2 stars, Star3 for 1 star visually on the menu
	if stars_count >= 1:
		s3.modulate = Color.yellow # 1st star to light up (e.g., rightmost or bottommost)
	if stars_count >= 2:
		s2.modulate = Color.yellow # 2nd star
	if stars_count >= 3:
		s1.modulate = Color.yellow # 3rd star (e.g., leftmost or topmost)

# Call this when transitioning away from the level complete screen (e.g., "Next Level" button)
func hide_level_complete_and_unpause():
	Global.set_level_complete_status(false)
	level_complete_menu.visible = false
	# Only unpause if the pause menu ISN'T also trying to keep it paused
	if get_tree().paused: # Only unpause if it was paused by level complete
		get_tree().paused = false
		
func _on_Global_time_added(seconds: float):
	if level_timer_node:
		var new_time = level_timer_node.time_left + seconds
		level_timer_node.stop()
		level_timer_node.start(new_time)
		print("GUI: Added", seconds, "seconds. New time:", new_time)


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
	get_tree().change_scene(Global.getter_for_path_next_scene())


func _on_MainMenu_pressed():
#	print("DEBUG: _on_LC_MainMenuButton_pressed CALLED")
	Global.set_level_complete_status(false)
	get_tree().paused = false
	Global.reset_score()
	Global.reset_player_stats()
	print("mainmenu button pressed")
	get_tree().change_scene("res://src/MainMenu.tscn")

# for testing / debugging
func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		show_level_complete()
	if event.is_action_pressed("debugging"):
		print("Save Reset: changed to level 1")
		Global.save_player_progress("res://src/levels/Level1.tscn")
