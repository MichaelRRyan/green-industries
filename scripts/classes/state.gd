class_name State
extends Node

var state_machine = null

func enter(_parent) -> void:
	pass

func exit(_msg : = {}) -> void:
	queue_free()
	pass

func update(_delta : float) -> void:
	pass