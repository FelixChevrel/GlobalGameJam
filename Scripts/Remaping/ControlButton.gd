extends Button

@export var action : String = "move_right"
@export var bonus : String = ""
@export var idModifier : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_input(false)
	display_key()
	pass # Replace with function body.


func display_key():
	var t = "%s" % InputMap.action_get_events(action)[get_keyboardId()].as_text()
	text = t.replace("(Physical)", "")



func _toggled(toggled_on):
	set_process_unhandled_input(toggled_on)
	if (toggled_on): 
		text = "..."
		release_focus()
	else :
		display_key()
		grab_focus()
	

func _unhandled_input(event):
	if event.pressed:
		InputMap.action_erase_event(action, InputMap.action_get_events(action)[get_keyboardId()])
		InputMap.action_add_event(action, event)
		button_pressed = false
	
	var o = 0
	for i in InputMap.action_get_events(action) :
		
		if (i == event) :
			idModifier = o
			break
		
		o += 1
	
	AutoloadScript.KeyboardControlREf[action] = idModifier
	display_key()

func get_keyboardId() -> int:
	
	
	return AutoloadScript.KeyboardControlREf.get(action + bonus)
