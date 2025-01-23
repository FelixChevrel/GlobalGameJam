extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_return_pressed():
	get_tree().paused = false
	$".".visible = false
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(AutoloadScript.mainMenu)
	pass # Replace with function body.


func _on_options_pressed():
	$ColorRect.visible = true
	pass # Replace with function body.


func _on_color_rect_closed_options():
	$ColorRect.visible = false
	pass # Replace with function body.

func _input(event):
	if (event.is_action_pressed("pause")):
		
		get_tree().paused = true
		$".".visible = true
	
