extends AnimatableBody2D

@export var maxWeight : float = 10
var currentWeight : float = 0
var maxHeight : Vector2 = Vector2(0,0)
var minHeight : Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	maxHeight = global_position
	minHeight = $EndPoint.global_position
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var bodies = $CollisionShape2D/Area2D.get_overlapping_bodies()
	currentWeight = 0
	
	
	for b in bodies :
		
		if b.is_in_group("water"):
			
			currentWeight += b.waterAmount
		if (currentWeight >= 10):
			currentWeight = 10
			break
		
	
	var fp = (((minHeight - maxHeight)/maxWeight) * currentWeight) + maxHeight
	
	var tween = get_tree().create_tween()
	tween.tween_property($CollisionShape2D, "global_position", fp, 5)
	
	pass
