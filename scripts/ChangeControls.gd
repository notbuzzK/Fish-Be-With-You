extends OptionButton

export (NodePath) var dropdown_path
onready var changeControl = get_node(dropdown_path)

func _ready():
	add_items()
	

func add_items():
	changeControl.add_item("WASD", 0)
	changeControl.add_item("Arrow Keys", 1)


func _on_ChangeControls_item_selected(index):
	print(changeControl.get_item_text(index))
