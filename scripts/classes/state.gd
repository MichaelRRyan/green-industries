class_name State
extends Node

var _ai = null
var state_machine = null

# ------------------------------------------------------------------------------
func enter(parent) -> void:
	_ai = parent
	
	
# ------------------------------------------------------------------------------
func exit(_msg : = {}) -> void:
	queue_free()

	
# ------------------------------------------------------------------------------
func update(_delta : float) -> void:
	pass
	
	
# ------------------------------------------------------------------------------
