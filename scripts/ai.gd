extends Node2D

var buying = 0
var ai_data = null
var ai_resource = null
var resource_manager = Utility.get_dependency("resource_manager", self, true)
var ai_invertry = {}
onready var is_active = false
var _command_factory : CommandFactories.CommandFactory = null
var _player_data_manager = Utility.get_dependency("player_data_manager")
onready var _timer = get_node("BuyTileTimer")
onready var _place_building_timer = get_node("PlaceBuildingTimer")
onready var _resource_timer = get_node("BuyResourceTimer")
const TILE_MAP_SIZE = 100
var controlled_tiles = []
var controlled_tiles_dict : Dictionary = {}

var _terrain = null
onready var _state_machine = get_node("StateMachine")

var _resource_manager


# ------------------------------------------------------------------------------
func _ready():
	_terrain = Utility.get_dependency("terrain", self, true)
	_resource_manager = Utility.get_dependency("resource_manager", self, true)
	#make sure that the command factory gets a chance to be loaded before trying to access it
	call_deferred("_get_factory")


# ------------------------------------------------------------------------------
func _process(_delta):
	if ai_data:
		_state_machine.update(_delta)


# ------------------------------------------------------------------------------
func add_to_controlled(_tile_pos : Vector2):
	controlled_tiles.push_back(_tile_pos)
	
	var tile = _terrain.get_cellv(_tile_pos)
	if controlled_tiles_dict.has(tile):
		controlled_tiles_dict[tile].append(_tile_pos)
	else:
		controlled_tiles_dict[tile] = [_tile_pos]


# ------------------------------------------------------------------------------
func change_type(_tile_pos : Vector2, new_tile_type):
	
	for tile_type in controlled_tiles_dict:
		var pos = controlled_tiles_dict[tile_type].find(_tile_pos)
		if pos != -1:
			controlled_tiles_dict[tile_type].remove(pos)
			if controlled_tiles_dict[tile_type].empty():
				var _r = controlled_tiles_dict.erase(tile_type)
			break
		
	if controlled_tiles_dict.has(new_tile_type):
		controlled_tiles_dict[new_tile_type].append(_tile_pos)
	else:
		controlled_tiles_dict[new_tile_type] = [_tile_pos]


# ------------------------------------------------------------------------------
func _get_factory():
	_command_factory = Utility.get_dependency("command_tool", self, true).command_factory
	resource_manager = Utility.get_dependency("resource_manager", self, true)
	_state_machine.transition_to(States.StartState)


# ------------------------------------------------------------------------------
func _set_player_data(player_data) -> void:
	ai_data = player_data
	ai_data.connect("resource_harvested", self, "_on_resource_harvested")
	is_active = true


# ------------------------------------------------------------------------------
# Checks if a resource has been harvested and updates the tile.
func _on_resource_harvested(resource : ResourceType):
	# Checks all owned forest resources.
	if controlled_tiles_dict.has(Tile.Type.FOREST):
		for forest_pos in controlled_tiles_dict[Tile.Type.FOREST]:
			var tile_type = _terrain.get_cellv(forest_pos)
			if Tile.Type.FOREST != tile_type:
				change_type(forest_pos, tile_type)
				print("Wood tile harvested")
				return # No more than ne should have changed.
	
	# Checks all owned stone resources.
	if controlled_tiles_dict.has(Tile.Type.STONE):
		for stone_pos in controlled_tiles_dict[Tile.Type.STONE]:
			var tile_type = _terrain.get_cellv(stone_pos)
			if Tile.Type.STONE != tile_type:
				change_type(stone_pos, tile_type)
				print("Stone tile harvested")
				return # No more than ne should have changed.


# ------------------------------------------------------------------------------
func _set_inactive() -> void:
	ai_data = null


# ------------------------------------------------------------------------------
func _on_BuyTileTimer_timeout():
	_state_machine.transition_to(States.BuyLandState)


# ------------------------------------------------------------------------------
func _on_PlaceBuildingTimer_timeout():
	_state_machine.transition_to(States.PlaceHarvesterState)


# ------------------------------------------------------------------------------
# Buys  or sells the resource
func _on_BuyResourceTimer_timeout():
	_state_machine.transition_to(States.BuyResourceState)
	

# ------------------------------------------------------------------------------
func _on_SellResourceTimer_timeout():
	_state_machine.transition_to(States.SellResourceState)
	

# ------------------------------------------------------------------------------
