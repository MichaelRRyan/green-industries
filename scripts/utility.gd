extends Node

const _BUTTON_EXPAND_SCALE = Vector2(1.02, 1.02)
const _BUTTON_ANIMATION_LENGTH = 0.1
const _BUTTON_TRANS_TYPE = Tween.TRANS_BOUNCE
const _BUTTON_EASE_TYPE = Tween.EASE_IN_OUT


# ------------------------------------------------------------------------------
func get_dependency(group_name : String, caller : Node = null, 
					 is_vital : bool = false) -> Node:
						
	var dependency = null
	var caller_name = caller.name if caller else "A script"
	
	# Tries to retrieve a dependency in the given group.
	var list = get_tree().get_nodes_in_group(group_name)
	if not list.empty():
		dependency = list.front()
		
	# If no dependency object is found, throws a warning.
	else:
		
		# If the dependency is vital, stop processing.
		if is_vital and caller:
			caller.set_process(false)
			caller.set_process_input(false)
			caller.set_physics_process(false)
			print_debug("WARNING: " + caller_name + " cannot find a '" 
				+ group_name + "'. The object will not process.")
			
		else:
			print_debug("WARNING: " + caller_name + " cannot find a '"
				+ group_name + "'. The object may not function as intended.")
		
	return dependency


# ------------------------------------------------------------------------------
# Ugly but quick enough method to get all neighbours.
func get_neighbours(cell : Vector2) -> Array:
	var neighbours = []
	

	if int(cell.y) % 2 == 0: # If even.
		neighbours.append(Vector2(cell.x - 1, cell.y - 1)) # Top left
		neighbours.append(Vector2(cell.x, cell.y - 1)) # Top right
		neighbours.append(Vector2(cell.x + 1, cell.y)) # Middle right
		neighbours.append(Vector2(cell.x, cell.y + 1)) # Bottom right
		neighbours.append(Vector2(cell.x - 1, cell.y + 1)) # Bottom left
		neighbours.append(Vector2(cell.x - 1, cell.y)) # Middle left
	else:
		neighbours.append(Vector2(cell.x, cell.y - 1)) # Top left
		neighbours.append(Vector2(cell.x + 1, cell.y - 1)) # Top right
		neighbours.append(Vector2(cell.x + 1, cell.y)) # Middle right
		neighbours.append(Vector2(cell.x + 1, cell.y + 1)) # Bottom right
		neighbours.append(Vector2(cell.x, cell.y + 1)) # Bottom left
		neighbours.append(Vector2(cell.x - 1, cell.y)) # Middle left
		

	return neighbours


# ------------------------------------------------------------------------------
func get_currency_format_string(number : int) -> String:
	var string = str(number)

	# Adds commas every 3 numbers from the back of the string.
	for i in range(3, string.length(), 3):
		#warning-ignore:integer_division
		var index = string.length() - (i + (i / 3) - 1)
		string = string.insert(index, ",")
	
	# Assigns the new text.
	return "$" + string


# ------------------------------------------------------------------------------
func setup_button_animations(tween : Tween) -> void:
	# Gets the buttons and connects their signals to animate them.
	var buttons = get_tree().get_nodes_in_group("button")
	for button in buttons:
		button.connect("focus_entered", self, "_button_animate_expand", [button, tween])
		button.connect("mouse_entered", self, "_button_animate_expand", [button, tween])
		button.connect("focus_exited", self, "_button_animate_shrink", [button, tween])
		button.connect("mouse_exited", self, "_button_animate_shrink", [button, tween])


# ------------------------------------------------------------------------------
func _button_animate_expand(button : Button, tween : Tween):
	var _r = tween.interpolate_property(button, "rect_scale", Vector2.ONE, _BUTTON_EXPAND_SCALE,
		_BUTTON_ANIMATION_LENGTH, _BUTTON_TRANS_TYPE, _BUTTON_EASE_TYPE)
	_r = tween.start()


# ------------------------------------------------------------------------------
func _button_animate_shrink(button : Button, tween : Tween):
	var _r = tween.interpolate_property(button, "rect_scale", _BUTTON_EXPAND_SCALE, Vector2.ONE,
		_BUTTON_ANIMATION_LENGTH, _BUTTON_TRANS_TYPE, _BUTTON_EASE_TYPE)
	_r = tween.start()


# ------------------------------------------------------------------------------
