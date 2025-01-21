extends RigidBody2D


@export var waterAmount : float = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	mass = waterAmount * 0.01
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	
	if (body.is_in_group("Player")) :
		
		
		
		body.gainWater(waterAmount)
		
		print(waterAmount)
		
		queue_free()
	
	


func _on_timer_timeout():
	$Area2D/CollisionPolygon2D.disabled = false
	pass # Replace with function body.

func initializeSize():
	
	scale = Vector2(waterAmount/2, waterAmount/2)
	
