extends Control


func _input(event):
	if event.is_action_pressed("paused"):
		var pause_state = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state


func _on_Exit_pressed():
	get_tree().paused = false
	var _value = get_tree().change_scene("res://scenes/main_menu.tscn");


func _on_Options_pressed():
	$Settings.visible = true


func _on_Play_pressed():
	get_tree().paused = false
	hide()
	
