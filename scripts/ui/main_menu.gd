extends Control

var _focus_grabbed = false
var buttons = []


# ------------------------------------------------------------------------------
func _on_Play_pressed():
	var _value = get_tree().change_scene("res://scenes/ui/lobby.tscn");


# ------------------------------------------------------------------------------
func _on_Options_pressed():
	var _set = get_tree().change_scene("res://scenes/ui/settings.tscn");


# ------------------------------------------------------------------------------
func _on_Exit_pressed():
	get_tree().quit();


# ------------------------------------------------------------------------------
func _ready():
	# Resets the network upon entering the main menu.
	Network.close_connection()
	Network.state = Network.State.OFFLINE
	
	Utility.setup_button_animations($Tween)
	buttons = get_tree().get_nodes_in_group("button")

	# If the buttons array is empty, run _input(event).
	if buttons.empty():
		set_process_input(false)

# ------------------------------------------------------------------------------
func _input(event):
	# If focus has yet to have been grabbed.
	if not _focus_grabbed:
		
		# If the input event is a key or a controller.
		if (event is InputEventKey
			or event is InputEventJoypadButton
			or event is InputEventJoypadMotion):
					
				# Gives the first button focus and handles the input.
				buttons.front().grab_focus()
				_focus_grabbed = true
				get_tree().set_input_as_handled()
	
	# If the focus has been grabbed and the event is a mouse event.
	elif event is InputEventMouse:
		
		# Grabs focus and unfocuses again to leave no element focused.
		var button : Button = buttons.front()
		button.grab_focus()
		button.release_focus()
		_focus_grabbed = false
			

# ------------------------------------------------------------------------------


func _on_Help_pressed():
	var _set = get_tree().change_scene("res://scenes/Instructions.tscn");
