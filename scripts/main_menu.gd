extends Control


func _on_Play_pressed():
	var _value = get_tree().change_scene("res://scenes/lobby.tscn");


func _on_Options_pressed():
	var _set = get_tree().change_scene("res://scenes/settings.tscn");


func _on_Exit_pressed():
	get_tree().quit();
