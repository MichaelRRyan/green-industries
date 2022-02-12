extends Node2D

signal building_placed(building, type)


# ------------------------------------------------------------------------------
func _on_BuildTool_building_placed(building : Node2D, type : int) -> void:
	emit_signal("building_placed", building, type)


# ------------------------------------------------------------------------------
