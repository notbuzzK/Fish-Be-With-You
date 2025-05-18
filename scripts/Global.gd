extends Node

# global state management and information sharing in between multiple files

var current_score: int = 0
signal score_updated(new_score)

var is_level_complete: bool = false 

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
	# might be some values here that need to be updated to but cant think of any as of making ths

# different fish sizes, to be used by FishFood* and Boss
enum FishSize { SMOL, MEDIUM, LARGE, BOSS } 

# Player Size Tiers for Eating
# Example: player needs a "size points" of 20 to eat medium and 50 for large, can be changed for balancing
const CAN_EAT_MEDIUM_THRESHOLD = 20 
const CAN_EAT_LARGE_THRESHOLD = 50  

var player_current_health: int = 100
const PLAYER_MAX_HEALTH: int = 100
# custom signals, pwede kayo gumawa ng sarili niyo if may naisip kayong application
signal player_health_updated(new_health)
signal player_died

func take_player_damage(amount: int):
	player_current_health -= amount
	player_current_health = max(0, player_current_health) # Clamp health at 0
	emit_signal("player_health_updated", player_current_health)
	print("Player health: ", player_current_health)
	if player_current_health <= 0:
		emit_signal("player_died")

func reset_player_stats(): # Call this at level start/retry
	player_current_health = PLAYER_MAX_HEALTH
	emit_signal("player_health_updated", player_current_health)

func _ready():
	reset_score()
	reset_player_stats() # Reset health on game/global start
	pass
