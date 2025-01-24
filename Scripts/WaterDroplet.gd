extends RigidBody2D


@export var waterAmount : float = 1
@export var falling = false
@export var fallingSpeed = Vector2(0,500)
var projectile : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mass = waterAmount * 0.01
	
	pass # Replace with function body.print (position.y - apex.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (falling):
		
		position += delta * fallingSpeed
		
	
	
	pass


func _on_area_2d_body_entered(body):
	
	if (body.is_in_group("Player")) :
		
		
		
		body.gainWater(waterAmount)
		
		if falling :
			
			body.can_dash = true
		
		queue_free()
	
	if (body.is_in_group("Drinking")):
		body.waterHeld += waterAmount
		body.startAnim()
		queue_free()
	
	if (body.is_in_group("breakable")):
		
		body.queue_free()
		queue_free()
		
	
	if (falling) : queue_free()
	



func _on_timer_timeout():
	$Area2D/CollisionPolygon2D.disabled = false
	pass # Replace with function body.

func initializeSize():
	
	$Droplet.scale = (0.25 * Vector2(waterAmount, waterAmount) * 0.5) 
	$CollisionPolygon2D.scale = (Vector2(waterAmount, waterAmount) * 0.5) 
	$Line2D.scale = (Vector2(waterAmount, waterAmount) * 0.5) 
	$Area2D.scale = (Vector2(waterAmount, waterAmount) * 0.5) 
	
	


func _on_body_entered(body):
	if(falling) : queue_free()
	pass # Replace with function body.
