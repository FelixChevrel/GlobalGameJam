extends Node2D

@export var bubble : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	spawnBubble()
	
	pass


func spawnBubble():
	
	var newBubble = bubble.instantiate()
	newBubble.position = Vector2(0,0)
	newBubble.fallingSpeed = Vector2(0,0)
	newBubble.falling = true
	add_child(newBubble)
	



func _on_child_exiting_tree(node):
	
	await get_tree().create_timer(4).timeout
	
	spawnBubble()
	pass # Replace with function body.
