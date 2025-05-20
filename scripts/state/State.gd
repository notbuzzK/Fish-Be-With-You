# State.gd (Global state file)
extends Node
class_name State # This is good for type checking later

# Emitted when a state requests a transition
signal transitioned(new_state_name) # new_state_name will be a String

# All state methods should expect the 'owner' (the entity being controlled)
# and 'delta' where applicable.
# It's good practice to prefix unused parameters with an underscore.

func enter(_owner_node): # Now expects one argument
	pass

func exit(_owner_node): # Now expects one argument
	pass

# For logic not tied to physics (e.g., timers, animation triggers not physics-based)
func update(_delta, _owner_node): # Expects two arguments
	pass

# For movement, physics interactions
func physics_update(_delta, _owner_node): # Expects two arguments
	pass
