extends Node2D

onready var game_camera = $MainCamera
# onready var boss_node = $Boss # Set this path in the editor or find by group
onready var play_area = $PlayArea

func _ready():
	var boss_nodes_in_scene = get_tree().get_nodes_in_group("bosses") # Add boss to "bosses" group
	if boss_nodes_in_scene.size() > 0:
		var boss_node = boss_nodes_in_scene[0]
		if boss_node.is_connected("boss_defeated", self, "_on_Boss_defeated"):
			print("Boss defeated signal already connected.")
		else:
			var err = boss_node.connect("boss_defeated", self, "_on_Boss_defeated")
			if err != OK:
				print_debug("ERROR connecting boss_defeated signal: ", err)
	else:
		print_debug("No boss found in 'bosses' group to connect defeat signal.")
	
	Global.advance_to_next_level()

func onPlayerTakeDamageFromTrash():
	Global.take_player_damage(1)

func _on_Boss_defeated():
	print("LEVEL COMPLETE! Boss was defeated.")
	# Access your GUI to show the level complete screen
	var gui_node = get_node_or_null("/root/Level1/CanvasLayer/GUI") # Adjust path as necessary
	if gui_node and gui_node.has_method("show_level_complete"):
		gui_node.show_level_complete()
	else:
		print_debug("Could not find GUI or show_level_complete method.")
	# You might also want to stop other game elements, save progress, etc.
