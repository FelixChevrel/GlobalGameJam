extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

signal closedOptions


func _on_button_pressed():
	emit_signal("closedOptions")
	pass # Replace with function body.


func _on_button_2_pressed():
	AutoloadScript.Checkpoint = Vector2(0,0)
	pass # Replace with function body.
