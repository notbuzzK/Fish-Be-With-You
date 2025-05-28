extends Control

#NOTE! always naka on yung pong scene 1, text1, hearts, stars, time at progress bar w/o highlight
#then off na the rest. ACADJIADHIADJH nalilito na q sa node structure
#node references

#onready var bar = 
#onready var bar_1= 
#onready var bar_2=
#onready var time = 
#onready var stars = 
#onready var stars_highlight=
onready var next_button= $fg/next
onready var heart
onready var heart_highlight= $hearts/heartshighlight
onready var scene1= $scene1
onready var scene2= $scene2
onready var scene3= $scene3
onready var scene4=$scene4
onready var scene5=$scene5
onready var scene6=$scene6
onready var scene7=$scene7
onready var scene8=$scene8
onready var scene9=$scene9
onready var scene10=$scene10
onready var scene11=$scene11
onready var scene12=$scene12
onready var scene13=$scene13
onready var scene14=$scene14
onready var scene15=$scene15
# Track how many times the "Next" button has been pressed
var step = 0

func _ready():
	pass # Replace with function body.



func _on_next_pressed():
	step += 1
	
	match step:
			1:
				scene1.visible= false
				scene2.visible= true
				next_button.rect_position = Vector2(549, 303)
			
			2:
				scene2.visible= false
				scene3.visible=true
				next_button.rect_position = Vector2(851, 285)
			3:
				scene3.visible= false
				scene4.visible=true
				next_button.rect_position = Vector2(851, 285)
			4:
				scene4.visible= false
				scene5.visible=true
				next_button.rect_position = Vector2(851, 285)
			5:
				scene5.visible= false
				scene6.visible=true
				next_button.rect_position = Vector2(907,249)
			6:
				scene6.visible= false
				scene7.visible=true
				next_button.rect_position = Vector2(587,329)
			7:
				scene7.visible= false
				scene8.visible=true
				next_button.rect_position = Vector2(587,329)
			8:
				scene8.visible= false
				scene9.visible=true
				next_button.rect_position = Vector2(587,329)
			9:
				scene9.visible= false
				scene10.visible=true
				next_button.rect_position = Vector2(1031, 223)
			10: 
				scene10.visible= false
				scene11.visible=true
				next_button.rect_position = Vector2(1031, 223)
			11:
				scene11.visible= false
				scene12.visible=true
				next_button.rect_position = Vector2(1055,354)
			12:
				scene12.visible= false
				scene13.visible=true
				next_button.rect_position = Vector2(1055,354)
			13:
				scene13.visible= false
				scene14.visible=true
				next_button.rect_position = Vector2(1055,354)
			14:
				scene14.visible= false
				scene15.visible=true
				next_button.rect_position = Vector2(1055,354)
			15: 
				get_tree().change_scene("res://src/levels/Level1.tscn")
