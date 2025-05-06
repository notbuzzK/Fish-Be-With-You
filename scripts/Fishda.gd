extends KinematicBody2D

# Player stats
var score: int = 0

# movement params
export var speed: int = 200

var velocity: Vector2 = Vector2()
onready var sprite = $Sprite

func _physics_process(_delta):
	velocity = Vector2.ZERO
	
	# player movement
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_up"):
		velocity.y -= speed
	if Input.is_action_pressed("move_down"):
		velocity.y += speed

	move_and_slide(velocity)

	# flip sprite based on horizontal motion
	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true

# function for 
func ate_fish(value):
	score += value
	print("Score is now %d" % score)
	
