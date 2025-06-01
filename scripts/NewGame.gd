extends Button

func _ready():
	pass

# connect to node tab
func _on_Button_pressed():
	get_tree().change_scene("res://src/components/how2play.tscn")
	print("Hello World")

