# StateMachine.gd
extends Node
class_name StateMachine # Optional, but can be useful

# Export a NodePath to the initial state node
export (NodePath) var initial_state_node_path # This will be set in the Inspector

var current_state: State # Will hold the actual state node instance
var states: Dictionary = {} # String name to State node instance

# The StateMachine needs a reference to its owner (the Boss Area2D)
# to pass to the states.
onready var owner_node = get_parent() # Assuming StateMachine is a direct child of the Boss Area2D

func _ready():
	# Ensure owner_node is valid (should be the Boss Area2D)
	if not owner_node:
		print("ERROR (StateMachine): Owner node not found! StateMachine should be a child of the entity it controls.")
		return

	# Populate the states dictionary from child nodes
	for child in get_children():
		if child is State: # Check if the child script extends your State class
			states[child.name.to_lower()] = child
			# Connect the child state's 'transitioned' signal to this StateMachine's handler
			child.connect("transitioned", self, "on_child_state_transition")
		else:
			print("StateMachine child ", child.name, " is not a State.")

	# Set the initial state
	if not initial_state_node_path.is_empty():
		var initial_state_node = get_node_or_null(initial_state_node_path)
		if initial_state_node and initial_state_node is State:
			current_state = initial_state_node
			current_state.enter(owner_node) # Pass owner to the initial state's enter method
			print("StateMachine: Initial state set to -> ", current_state.name)
		else:
			print("ERROR (StateMachine): Initial state node not found or not a valid State at path: ", initial_state_node_path)
			# Fallback: try to get the first state child if no initial path is set
			if states.size() > 0:
				current_state = states.values()[0]
				current_state.enter(owner_node)
				print("StateMachine: Fallback - Initial state set to first child -> ", current_state.name)

	if not current_state:
		print("ERROR (StateMachine): No initial state could be set!")


func _process(delta):
	if current_state:
		current_state.update(delta, owner_node) # Pass owner

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta, owner_node) # Pass owner

# Renamed for clarity and to match the signal name from State.gd
func on_child_state_transition(new_state_name_string: String):
	# No need to check 'state != current_state' because only the current_state's signal
	# should ideally be processed if states are well-behaved (don't emit when not active).
	# However, a check can be a safeguard.
	# if state_that_emitted != current_state:
	# 	return

	var new_state_node = states.get(new_state_name_string.to_lower())
	
	if not new_state_node:
		print("ERROR (StateMachine): Tried to transition to non-existent state: ", new_state_name_string)
		return
	
	if new_state_node == current_state:
		print("StateMachine: Tried to transition to the same state: ", new_state_name_string)
		return # Already in this state

	if current_state:
		current_state.exit(owner_node) # Pass owner
	
	new_state_node.enter(owner_node) # Pass owner
	current_state = new_state_node
	print("StateMachine: Transitioned to -> ", current_state.name)
