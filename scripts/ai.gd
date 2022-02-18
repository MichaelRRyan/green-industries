extends Node2D


var ai_data = null
onready var is_active = false
var _command_factory : CommandFactories.CommandFactory = null
var _player_data_manager = Utility.get_dependency("player_data_manager")
onready var _timer = get_node("BuyTileTimer")
onready var _place_building_timer = get_node("PlaceBuildingTimer")
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

func _set_player_data(player_data) -> void:
	ai_data = player_data
	is_active = true
	
func _start_timer() -> void:
	_timer.set_wait_time( 2 )
	_timer.start()

func _set_inactive() -> void:
	is_active = false
	ai_data = null
	
func _on_BuyTileTimer_timeout():
	_state_machine.transition_to(States.NoLandState)
	var buy_tile : Vector2 = Vector2(randi() % TILE_MAP_SIZE, randi() % TILE_MAP_SIZE)
	var still_looking = true
	while _player_data_manager.owner_dict.has(buy_tile) or still_looking and is_active:
		buy_tile = Vector2(randi() % TILE_MAP_SIZE, randi() % TILE_MAP_SIZE)
		var neighbours = Utility.get_neighbours(buy_tile)
		var contains_trees = false
		var contains_minerals = false
		for neighbour in neighbours:
			if _terrain.get_cellv(neighbour) == Tile.Type.FOREST:
				contains_trees = true
			elif _terrain.get_cellv(neighbour) == Tile.Type.STONE:
				contains_minerals = true
		if _terrain.get_cellv(buy_tile) == Tile.Type.GRASS and (contains_trees or contains_minerals):
			still_looking = false
	if is_active:
		var command = _command_factory.create_buy_land_command(buy_tile, ai_data.id)
		command.execute()
		controlled_tiles.push_back(buy_tile)
		_place_building_timer.start()
		print("found tile at: " + "(" + str(buy_tile.x) + ", " + str(buy_tile.y) + ")")
		_state_machine.transition_to(States.IdleState)


func _on_PlaceBuildingTimer_timeout():
	_state_machine.transition_to(States.NoResourceState)
	if is_active:
		var neighbours = Utility.get_neighbours(controlled_tiles.front())
		var contains_trees = false
		var contains_minerals = false
		for neighbour in neighbours:
			if _terrain.get_cellv(neighbour) == Tile.Type.FOREST:
				contains_trees = true
			elif _terrain.get_cellv(neighbour) == Tile.Type.STONE:
				contains_minerals = true
		var build_type = null
		if contains_trees:
			build_type = Tile.Type.LUMBERJACK
		elif contains_minerals:
			build_type = Tile.Type.MINE
		var buy_tile : Vector2 = Vector2(randi() % TILE_MAP_SIZE, randi() % TILE_MAP_SIZE)
		for neighbour in neighbours:
			if _terrain.get_cellv(neighbour) == Tile.Type.FOREST and build_type == Tile.Type.LUMBERJACK:
				buy_tile = neighbour
				break
			elif _terrain.get_cellv(neighbour) == Tile.Type.STONE and build_type == Tile.Type.MINE:
				buy_tile = neighbour
				break
		if build_type != null:
			var command = _command_factory.\
				create_build_command(controlled_tiles.front(), build_type, ai_data.id)
			command.execute()
			command = _command_factory.create_buy_land_command(buy_tile, ai_data.id)
			command.execute()
			controlled_tiles.push_back(buy_tile)
			_state_machine.transition_to(States.IdleState)

