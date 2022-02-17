extends Node2D


var ai_data = null
onready var is_active = false
var _command_factory : CommandFactories.CommandFactory = null
var _player_data_manager = Utility.get_dependency("player_data_manager")
onready var _timer = get_node("BuyTileTimer")
onready var _place_building_timer = get_node("PlaceBuildingTimer")
onready var _wait_timer = get_node("WaitTimer")
const TILE_MAP_SIZE = 100
var controlled_tiles = []
var _terrain = null
onready var _state_machine = get_node("StateMachine")

func _ready():
	_terrain = Utility.get_dependency("terrain", self, true)
	#make sure that the command factory gets a chance to be loaded before trying to access it
	call_deferred("_get_factory")
	call_deferred("_start_timer")


# ------------------------------------------------------------------------------
func _get_factory():
	_command_factory = Utility.get_dependency("command_tool", self, true).command_factory
	_state_machine.transition_to(States.StartState)

func _set_player_data(player_data) -> void:
	ai_data = player_data
	is_active = true
	
func _start_timer() -> void:
	#_timer.set_wait_time( 2 )
	#_timer.start()
	pass

func _set_inactive() -> void:
	is_active = false
	ai_data = null
	
func _on_BuyTileTimer_timeout():
	_state_machine.transition_to(States.BuyLandState)


func _on_PlaceBuildingTimer_timeout():
	_state_machine.transition_to(States.PlaceHarvesterState)

func _on_WaitTimer_timeout():
	_state_machine.transition_to(States.IdleState)
