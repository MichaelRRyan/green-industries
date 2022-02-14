extends Node2D

signal building_placed(building, type)


# ------------------------------------------------------------------------------
func _on_BuildTool_building_placed(building : Node2D, type : int, owner_id : int) -> void:
	emit_signal("building_placed", building, type, owner_id)


# ------------------------------------------------------------------------------
