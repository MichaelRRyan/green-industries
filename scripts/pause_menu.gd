extends Control


# ------------------------------------------------------------------------------
func toggle() -> void:
	visible = not get_tree().paused
	get_tree().paused = visible


# ------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("paused"):
		toggle()


# ------------------------------------------------------------------------------
func _on_Exit_pressed():
	get_tree().paused = false
	var _value = get_tree().change_scene("res://scenes/main_menu.tscn");


# ------------------------------------------------------------------------------
func _on_Options_pressed():
	$Settings.show()


# ------------------------------------------------------------------------------
func _on_Play_pressed():
	get_tree().paused = false
	hide()
	

# ------------------------------------------------------------------------------
func _on_Pollution_pressed():
	$Pollution.show()
	

# ------------------------------------------------------------------------------
func _on_pollution_Exit_pressed():
	show()
	$Pollution.hide()


# ------------------------------------------------------------------------------



