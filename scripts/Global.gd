extends Node

# global state management and information sharing in between multiple files

var path_to_next_scene
var current_score: int = 0
signal score_updated(new_score)

#current size points to eat
signal current_size_updated
var current_size_points := 0 setget set_current_size_points
func set_current_size_points(value):
	current_size_points = value
	emit_signal("current_size_updated")
#signals the fish count
signal fish_eaten_updated(new_count)
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

#for food count
var fish_eaten_count := 0 setget set_fish_eaten_count



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

func reset_score(): ##I CCHANGED THIS FROM RESET_SCORE TO RESET STATE FOR FISH COUNT
	current_score = 0
	is_level_complete = false
	emit_signal("score_updated", current_score)

	reset_player_stats()
	current_size_points = 0
	set_fish_eaten_count(0)


func get_score() -> int:
	return current_score

func set_level_complete_status(status: bool):
	is_level_complete = status
	Global.save_player_progress(path_to_next_scene)

func get_path_to_next_scene(next_scene):
	path_to_next_scene = next_scene
	print(next_scene)

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
	var file = File.new()
	file.open("user://save_game.dat", File.WRITE)
	print(content)
	file.store_string(content)
	file.close()

func load_player_progress():
	var file = File.new()
	file.open("user://save_game.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	return content

func _ready():
	reset_score()
	reset_player_stats() # Reset health on game/global start
	pass

#for food count
func set_fish_eaten_count(value):
	fish_eaten_count = value
	print("Global: fish_eaten_count set to ", fish_eaten_count)
	emit_signal("fish_eaten_updated", fish_eaten_count)


