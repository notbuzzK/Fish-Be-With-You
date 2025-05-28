extends Node

onready var bg_music = $"../bg_music1"  # player for menu scenes
onready var bgm_1 = $"../bgm1"          # player for Level1
onready var button_sfx = $"../button" #for everytime a player clicks a button

var scene_music_map = {
	"MainMenu": "bg_music",
	"How2play": "bg_music",
	"Settings": "bg_music",
	"ChangeAppearance": "bg_music",
	"Level1": "bgm_1",
	"Level2": "bgm_1"
}

func _ready():
	get_tree().connect("current_scene_changed", self, "_on_scene_changed")
	
	var current_scene = get_tree().get_current_scene()
	if current_scene:
		_on_scene_changed(current_scene)

#this is for the button sound pero ndi parin nagana
func play_button_sound():
	if button_sfx:
		button_sfx.play()

#di pa nagana yung change scene
func _on_scene_changed(scene):
	var scene_name = scene.name
	
	# Stop all players first
	bg_music.stop()
	bgm_1.stop()

	# Check which one to play
	if scene_name in scene_music_map:
		var target_player = scene_music_map[scene_name]
		match target_player:
			"bg_music":
				bg_music.play()
			"bgm_1":
				bgm_1.play()
