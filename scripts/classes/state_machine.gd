extends Node

signal transitioned(state_name)

var state : State = States.IdleState.new()

func _ready() -> void:
	if state != null:
		state.state_machine = self
		state.enter()

func _process(_delta) -> void:
	state.update(_delta)

func transition_to(target_state, msg: Dictionary = {}) -> void:
	if state != null:
		state.exit()
	
	state = target_state.new()
	state.enter(msg)
	emit_signal("transitioned", state.name)
