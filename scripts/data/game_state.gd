extends Node

signal selected_tool_changed(new_tool, old_tool)

var _selected_tool = Tool.Type.SELECT setget set_selected_tool, get_selected_tool


# ------------------------------------------------------------------------------
func set_selected_tool(type : int) -> void:
	if _selected_tool != type:
		emit_signal("selected_tool_changed", type, _selected_tool)
		
	_selected_tool = type


# ------------------------------------------------------------------------------
func get_selected_tool() -> int:
	return _selected_tool


# ------------------------------------------------------------------------------
