extends Control

onready var _volume_progress = find_node("VolumeProgress")

func _on_Exit_pressed():
	hide()


func _on_HSlider_value_changed(value):
	_volume_progress.value = value
