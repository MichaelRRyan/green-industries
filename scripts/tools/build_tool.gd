extends Node2D

signal building_placed(building, type)

var building_type : int = Tile.Type.LUMBERJACK

var _terrain = null
var _world = null
var _buy_tool = null

onready var BuildingScenes = {
	Tile.Type.LUMBERJACK: preload("res://scenes/buildings/lumberjack.tscn"),
	Tile.Type.MINE: preload("res://scenes/buildings/mine.tscn"),
	Tile.Type.FACTORY: preload("res://scenes/factory.tscn"),
	Tile.Type.POWER_PLANT: preload("res://scenes/coal_power_plant.tscn"),
}


# ------------------------------------------------------------------------------
func set_building_type(type : int) -> void:
	building_type = type

remote func request_build(tile_pos: Vector2, building_type: int) -> void:
	if _terrain.is_tile_empty(tile_pos):			
		_terrain.set_cellv(tile_pos, building_type)
		var building = BuildingScenes[building_type].instance()		
		#sending the other clients where the building was placed
		rpc("place_building_remote", tile_pos, building_type)
		building.set_network_master(get_tree().get_network_unique_id())
			
		# Places the building uniformly on a tile corner.
		building.position = (_terrain.get_global_position_from_tile(tile_pos) +
			_terrain.tile_size * 0.5)
		
		_world.add_child(building)
		emit_signal("building_placed", building, building_type)
# ------------------------------------------------------------------------------
func place_building(tile_pos : Vector2) -> bool:
	if Network.is_client():
		rpc_id(1, "request_build", tile_pos, building_type)
		return true
	if _terrain.is_tile_empty(tile_pos):			
		_terrain.set_cellv(tile_pos, building_type)
		var building = BuildingScenes[building_type].instance()
		
		#sending the other clients where the building was placed
		if Network.is_online:
			rpc("place_building_remote", tile_pos, building_type)
			building.set_network_master(get_tree().get_network_unique_id())
			
		# Places the building uniformly on a tile corner.
		building.position = (_terrain.get_global_position_from_tile(tile_pos) +
			_terrain.tile_size * 0.5)
		
		_world.add_child(building)
		emit_signal("building_placed", building, building_type)
		
		return true
	return false

remote func place_building_remote(tile_pos : Vector2, type : int) -> void:
	_terrain.set_cellv(tile_pos, type)
	var building = BuildingScenes[type].instance()
	building.set_network_master(get_tree().get_rpc_sender_id())
	# Places the building uniformly on a tile corner.
	building.position = (_terrain.get_global_position_from_tile(tile_pos) +
		_terrain.tile_size * 0.5)
		
	_world.add_child(building)
	emit_signal("building_placed", building, type)

# ------------------------------------------------------------------------------
func _ready() -> void:
	_world = Utility.get_dependency("world", self, true)
	_terrain = Utility.get_dependency("terrain", self, true)
	_buy_tool = Utility.get_dependency("buy_tool", self, true)


# ------------------------------------------------------------------------------
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("select"):
		# Needs to be extended to get the selection instead of the mouse pos.
		var mouse_pos = get_global_mouse_position()
		var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
		if !_buy_tool.buying:
			if _buy_tool.owner_dict.has(mouse_tile):
				if (Network.state == Network.State.SOLO and _buy_tool.owner_dict[mouse_tile].id == 1) \
					or _buy_tool.owner_dict[mouse_tile].id == get_tree().get_network_unique_id():
						var _success = place_building(mouse_tile)
			
		
		buy_tile_and_place_building(mouse_tile)
	
	if event.is_action_pressed("select_1"):
		building_type = Tile.Type.LUMBERJACK
	
	if event.is_action_pressed("select_2"):
		building_type = Tile.Type.MINE
	
	if event.is_action_pressed("select_3"):
		building_type = Tile.Type.FACTORY
		
	if event.is_action_pressed("select_4"):
		building_type = Tile.Type.POWER_PLANT


# ------------------------------------------------------------------------------
func buy_tile_and_place_building(tile_pos : Vector2) ->bool:
	if _buy_tool.check_availble(tile_pos) and _terrain.is_tile_empty(tile_pos):
			_buy_tool.buy_tile(tile_pos)
			place_building(tile_pos)
			return true
	return false
