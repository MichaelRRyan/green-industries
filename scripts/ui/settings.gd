extends Control


func _on_Back_pressed():
	var _value = get_tree().change_scene("res://scenes/main_menu.tscn");


func _ready():
	Utility.setup_button_animations($Tween)
