extends Area2D

func _ready():
	connect("body_entered", self, "_on_Life_body_entered")
	
func _on_Life_body_entered(body):
	if body.name == "Fishda":
		print("LIFE POWER-UP")
		if body.has_method("heal_player"):
			body.heal_player(1) #add 1 heart 
		queue_free()
		
