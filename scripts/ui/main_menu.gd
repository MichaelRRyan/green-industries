extends Control

const _BUTTON_EXPAND_SCALE = Vector2(1.02, 1.02)
const _BUTTON_ANIMATION_LENGTH = 0.1
const _BUTTON_TRANS_TYPE = Tween.TRANS_BOUNCE
const _BUTTON_EASE_TYPE = Tween.EASE_IN_OUT

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
	
	# Gets the buttons and connects their signals to animate them.
	buttons = get_tree().get_nodes_in_group("button")
	for button in buttons:
		button.connect("focus_entered", self, "_button_animate_expand", [button])
		button.connect("mouse_entered", self, "_button_animate_expand", [button])
		button.connect("focus_exited", self, "_button_animate_shrink", [button])
		button.connect("mouse_exited", self, "_button_animate_shrink", [button])

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
func _button_animate_expand(button : Button):
	var tween : Tween = $Tween
	var _r = tween.interpolate_property(button, "rect_scale", Vector2.ONE, _BUTTON_EXPAND_SCALE,
		_BUTTON_ANIMATION_LENGTH, _BUTTON_TRANS_TYPE, _BUTTON_EASE_TYPE)
	_r = tween.start()


# ------------------------------------------------------------------------------
func _button_animate_shrink(button : Button):
	var tween : Tween = $Tween
	var _r = tween.interpolate_property(button, "rect_scale", _BUTTON_EXPAND_SCALE, Vector2.ONE,
		_BUTTON_ANIMATION_LENGTH, _BUTTON_TRANS_TYPE, _BUTTON_EASE_TYPE)
	_r = tween.start()


# ------------------------------------------------------------------------------
