extends Node2D

signal building_placed(building, type)

var building_type : int = Tile.Type.LUMBERJACK

var _terrain = null
var _world = null

onready var BuildingScenes = {
	Tile.Type.LUMBERJACK: preload("res://scenes/buildings/lumberjack.tscn"),
	Tile.Type.MINE: preload("res://scenes/buildings/mine.tscn"),
	Tile.Type.FACTORY: preload("res://scenes/factory.tscn"),
}


# ------------------------------------------------------------------------------
func set_building_type(type : int) -> void:
	building_type = type


# ------------------------------------------------------------------------------
func place_building(tile_pos : Vector2) -> bool:
	if _terrain.is_tile_empty(tile_pos):
		_terrain.set_cellv(tile_pos, building_type)
		var building = BuildingScenes[building_type].instance()
		
		# Places the building uniformly on a tile corner.
		building.position = (_terrain.get_global_position_from_tile(tile_pos) +
			_terrain.tile_size * 0.5)
		
		_world.add_child(building)
		emit_signal("building_placed", building, building_type)
		return true
	
	return false


# ------------------------------------------------------------------------------
func _ready() -> void:
	_world = Utility.get_dependency("world", self, true)
	_terrain = Utility.get_dependency("terrain", self, true)


# ------------------------------------------------------------------------------
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("select"):
		
		# Needs to be extended to get the selection instead of the mouse pos.
		var mouse_pos = get_global_mouse_position()
		var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
		var _success = place_building(mouse_tile)
	
	if event.is_action_pressed("select_1"):
		building_type = Tile.Type.LUMBERJACK
	
	if event.is_action_pressed("select_2"):
		building_type = Tile.Type.MINE
	
	if event.is_action_pressed("select_3"):
		building_type = Tile.Type.FACTORY


# ------------------------------------------------------------------------------
