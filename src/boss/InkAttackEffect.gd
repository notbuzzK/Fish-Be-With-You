# InkAttackEffect.gd
extends Node2D # Or Control, Sprite, AnimatedSprite, depending on your root node type

onready var sprite_node = $Sprite # Or $AnimatedSprite, or self if root is a sprite type
onready var animation_player = $AnimationPlayer # If you have one
onready var duration_timer = $DurationTimer

# Export the duration so it can be set from the editor or by the boss
export var effect_duration: float = 3.0 # Default duration

func _ready():
	# Ensure it starts hidden (also set in editor, but good to be sure)
	visible = false 
	if duration_timer:
		duration_timer.connect("timeout", self, "_on_DurationTimer_timeout")
		duration_timer.one_shot = true # Ensure it's one-shot
	else:
		print_debug("ERROR (InkAttackEffect): DurationTimer node not found!")

	if not sprite_node:
		print_debug("ERROR (InkAttackEffect): Sprite node not found!")
	if animation_player and not animation_player.has_animation("Ink Attack"): # Replace with your animation name
		print_debug("WARNING (InkAttackEffect): Animation 'Ink Attack' not found in AnimationPlayer.")


# This function will be called via a signal from the boss
func trigger_effect():
	if not sprite_node: return

	print_debug("InkAttackEffect: Triggered!")
	visible = true

	if animation_player and animation_player.has_animation("Ink Attack"): # Replace with your animation name
		animation_player.play("Ink Attack")
	else: # Fallback if no animation, just make sprite visible
		sprite_node.visible = true # Should already be true from above, but good practice

	if duration_timer:
		duration_timer.wait_time = effect_duration
		duration_timer.start()
	else: # If no timer, it might stay visible forever or need manual hiding
		print_debug("InkAttackEffect: No duration timer, effect might not hide automatically.")


func _on_DurationTimer_timeout():
	print_debug("InkAttackEffect: Duration ended, hiding.")
	if animation_player and animation_player.has_animation("Ink Attack"): # Replace with your animation name
		animation_player.play_backwards("Ink Attack")
		yield(animation_player, "animation_finished")
		visible = false
