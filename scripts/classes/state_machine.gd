extends Node

signal transitioned(state_name)

var state : State = States.IdleState.new()

func _ready() -> void:
	if state != null:
		state.state_machine = self
		state.enter(get_parent()) 

func _process(_delta) -> void:
	state.update(_delta)

func transition_to(target_state) -> void:
	if state != null:
		state.exit()
	
	state = target_state.new()
	state.enter(get_parent())
	emit_signal("transitioned", state.name)
