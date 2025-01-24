@tool
extends Node2D

@export var droplet : PackedScene
@export var spawnArea : Vector2 = Vector2(50,50)
@export var timing : float = 1
@export var modifySpeed : bool = false
@export var newSpeed : Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if !Engine.is_editor_hint() :
		$DropTimer.wait_time = timing
		$Line2D.queue_free()
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint() :
		
		for i in 4 :
			
			match i :
				0 : $Line2D.points[i] = Vector2(-spawnArea.x,-spawnArea.y)
				1 : $Line2D.points[i] = Vector2(-spawnArea.x,spawnArea.y)
				2 : $Line2D.points[i] = Vector2(spawnArea.x,spawnArea.y)
				3 : $Line2D.points[i] = Vector2(spawnArea.x,-spawnArea.y)
			
		



func _on_drop_timer_timeout():
	
	var d = droplet.instantiate()
	
	var rx = randf_range(-spawnArea.x, spawnArea.x)
	var ry = randf_range(-spawnArea.y, spawnArea.y)
	
	d.position = position + Vector2(rx,ry)
	if (modifySpeed) :
		d.fallingSpeed = newSpeed
	get_tree().get_root().add_child(d)
	
	pass # Replace with function body.
