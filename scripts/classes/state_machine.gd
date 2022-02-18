extends Node

signal transitioned(state_name)

var _state : State = States.IdleState.new()

func _ready() -> void:
	if _state != null:
		_state.state_machine = self
		_state.enter(get_parent()) 

func update(_delta) -> void:
	_state.update(_delta)

func transition_to(target_state) -> void:
	if _state != null:
		_state.exit()
	
	_state = target_state.new()
	_state.enter(get_parent())
	emit_signal("transitioned", _state.name)

func _exit_tree():
	if _state != null:
		_state.queue_free()
