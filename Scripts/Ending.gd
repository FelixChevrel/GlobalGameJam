extends Area2D



func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		
		AutoloadScript.victory = true
		call_deferred("ValidateVictory")
		
	
	pass # Replace with function body.

func ValidateVictory():
	get_tree().change_scene_to_file("res://End_Screen.tscn")
	
