extends Node2D

@export var droplet : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_drop_timer_timeout():
	
	var d = droplet.instantiate()
	d.position = position
	get_tree().get_root().add_child(d)
	
	pass # Replace with function body.
