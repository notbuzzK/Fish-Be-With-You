extends Node

## from chatgpt aausin pa


var bg_music_player = AudioStreamPlayer.new()
var sfx_player = AudioStreamPlayer.new()

#var button_click = preload("res://sounds/button_click.wav")

func _ready():
	add_child(bg_music_player)
	add_child(sfx_player)

func play_music(stream: AudioStream, loop := true):
	bg_music_player.stop()
	bg_music_player.stream = stream
	bg_music_player.loop = loop
	bg_music_player.play()

func pause_music():
	bg_music_player.stream_paused = true

func resume_music():
	bg_music_player.stream_paused = false

func stop_music():
	bg_music_player.stop()

func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()

func play_button_click():
  #  play_sfx(button_click)
