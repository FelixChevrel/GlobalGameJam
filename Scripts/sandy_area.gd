extends Area2D

@export var waterDrainValue : float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	
	var actors = get_overlapping_bodies()
	
	for a in actors :
		
		if a.is_in_group("Player"):
			
			a.LoseWater(2, true)
			
		
		if a.is_in_group("water"):
			
			a.waterAmount -= 1
			
			if (a.waterAmount == 0):
				a.queue_free()
				
			
			a.initializeSize()
			
		
		
	
	pass # Replace with function body.
