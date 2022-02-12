extends Node

onready var _local_player = find_node("PlayerData")


# ------------------------------------------------------------------------------
func _on_Tools_building_placed(building : Node2D, type : int) -> void:
	_local_player.on_building_placed(building, type)


# ------------------------------------------------------------------------------
