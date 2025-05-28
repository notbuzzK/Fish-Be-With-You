extends Node

# global state management and information sharing in between multiple files

var path_to_next_scene
var current_score: int = 0
var selected_skin_index: int = 0
signal score_updated(new_score)

# Player Size Tiers for Eating
# Example: player needs a "size points" of 20 to eat medium and 50 for large, can be changed for balancing
export var CAN_EAT_MEDIUM_THRESHOLD = 20 
export var CAN_EAT_LARGE_THRESHOLD = 50  

# different fish sizes, to be used by FishFood* and Boss
enum FishSize { SMOL, MEDIUM, LARGE, BOSS } 

# different buffs
enum Buff { SPEED, REGEN, TIME_STOP }

# fishda (player) stats
var player_current_health: int = 100
const PLAYER_MAX_HEALTH: int = 3

func heal_player(amount: int):
	player_current_health += amount
	player_current_health = min(player_current_health, PLAYER_MAX_HEALTH)
	emit_signal("player_health_updated", player_current_health)
	print("Healed! Player health: ", player_current_health)


# custom signals, pwede kayo gumawa ng sarili niyo if may naisip kayong application
signal player_health_updated(new_health)
signal player_died

var is_level_complete: bool = false

func getter_for_path_next_scene():
	return path_to_next_scene

func add_score(amount: int):
	current_score += amount
	emit_signal("score_updated", current_score)
	print("Global score is now: ", current_score)

func reset_score():
	current_score = 0
	is_level_complete = false # Reset this too
	emit_signal("score_updated", current_score)

func get_score() -> int:
	return current_score

func set_level_complete_status(status: bool):
	is_level_complete = status
	Global.save_player_progress(path_to_next_scene)

func advance_to_next_level():
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("No current scene loaded.")
		return
	
	var current_scene_path = current_scene.filename
	var scene_name = current_scene_path.get_file().get_basename()  # e.g., "Level2"
	var level_number = scene_name.strip_edges("Level").to_int()  # Get the number part
	var next_level_number = level_number + 1
	var next_scene_path = "res://src/levels/Level%d.tscn" % next_level_number

	if ResourceLoader.exists(next_scene_path):
		path_to_next_scene = next_scene_path
		current_level_number = next_level_number
		print("Next level path set to:", path_to_next_scene)
	else:
		print("Next level scene doesn't exist:", next_scene_path)
		path_to_next_scene = ""  # Or go back to main menu, etc.

	
var current_level_number: int = 1

func get_path_to_next_scene(next_scene):
	current_level_number += 1
	path_to_next_scene = next_scene
	print(next_scene)
	print("Level", current_level_number)
	
func take_player_damage(amount: int):
	player_current_health -= amount
	player_current_health = max(0, player_current_health) 
	emit_signal("player_health_updated", player_current_health)
	print("Player health: ", player_current_health)
	if player_current_health <= 0:
		emit_signal("player_died")

func reset_player_stats(): # Call this at level start/retry
	player_current_health = PLAYER_MAX_HEALTH
	emit_signal("player_health_updated", player_current_health)

func save_player_progress(content):
	if typeof(content) != TYPE_STRING:
		print("save_player_progress: Invalid content, expected a string but got:", typeof(content))
		return
	var file = File.new()
	if file.open("user://save_game.dat", File.WRITE) == OK:
		file.store_string(content)
		file.close()
		print("Saved progress:", content)
	else:
		print("Failed to open save file.")

func load_player_progress():
	var file = File.new()
	file.open("user://save_game.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	return content
	
signal time_added(seconds)

func add_time_to_timer(seconds: float):
	print("Global: Requesting time extension of", seconds, "seconds")
	emit_signal("time_added", seconds)
	
func save_selected_skin():
	var file = File.new()
	if file.open("user://skin_data.save", File.WRITE) == OK:
		file.store_32(selected_skin_index)
		file.close()
		print("Skin index saved:", selected_skin_index)

func load_selected_skin():
	var file = File.new()
	if file.file_exists("user://skin_data.save"):
		if file.open("user://skin_data.save", File.READ) == OK:
			selected_skin_index = file.get_32()
			file.close()
			print("Loaded saved skin index:", selected_skin_index)

func _ready():
	load_selected_skin()
	reset_score()
	current_level_number = 1
	reset_player_stats() # Reset health on game/global start
	pass
