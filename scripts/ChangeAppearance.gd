extends Control

onready var settings_scene = $"."
export var used_in_main_menu: bool = true # flag


onready var preview_sprite = $SkinPreview
onready var next_button = $Next
onready var prev_button = $Previous
onready var save_button = $Save

var skin_textures = [
	preload("res://sprites/fishda/ANGEL.png"),
	preload("res://sprites/fishda/GEMMA.png"),
	preload("res://sprites/fishda/TILAPYUHH.png")
]

var current_index = 0

func _ready():
	current_index = clamp(Global.selected_skin_index, 0, skin_textures.size() - 1)
	update_skin_preview()
	
	next_button.connect("pressed", self, "_on_next_pressed")
	prev_button.connect("pressed", self, "_on_prev_pressed")
	save_button.connect("pressed", self, "_on_save_pressed")

func _on_next_pressed():
	current_index = (current_index + 1) % skin_textures.size()
	update_skin_preview()

func _on_prev_pressed():
	current_index = (current_index - 1 + skin_textures.size()) % skin_textures.size()
	update_skin_preview()

func _on_save_pressed():
	Global.selected_skin_index = current_index
	Global.save_selected_skin()

func update_skin_preview():
	preview_sprite.texture = skin_textures[current_index]
	print("Current skin index:", current_index)
	print("Using texture:", skin_textures[current_index].resource_path)
	preview_sprite.texture = skin_textures[current_index]

