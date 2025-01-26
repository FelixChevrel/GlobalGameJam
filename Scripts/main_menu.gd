extends Node2D




func _on_button_pressed():
	get_tree().change_scene_to_packed(AutoloadScript.level)
	pass # Replace with function body.


func _on_option_pressed():
	$ColorRect.visible = true
	pass # Replace with function body.


func _on_color_rect_closed_options():
	$ColorRect.visible = false
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
