extends Node2D

signal building_destroyed(position)

onready var _game_state = Utility.get_dependency("game_state", self, true)
onready var _world = Utility.get_dependency("world", self, true)
onready var _terrain = Utility.get_dependency("terrain", self, true)
onready var _networked_players = Utility.get_dependency("player_data_manager", self, true).networked_players


const CAN_PLACE_COLOUR : Color = Color(0 / 255,165.0 / 255,0,175.0 / 255)
const CANNOT_PLACE_COLOUR : Color = Color(165.0 / 255,0 / 255,0,175.0 / 255)
onready var colour = CAN_PLACE_COLOUR
onready var centre: Vector2 = Vector2(0,0)
var num_tiles = 0.5
var radius = 110 * num_tiles
var data = null
var resource_manager = null
var owner_dict = null


# ------------------------------------------------------------------------------
func _ready() -> void:
	resource_manager = Utility.get_dependency("resource_manager", self, true)
	data = Utility.get_dependency("player_data_manager", self, true).local_player_data
	var player_data_manager = Utility.get_dependency("player_data_manager", self, true)
	owner_dict = player_data_manager.owner_dict


# ------------------------------------------------------------------------------
func _unhandled_input(event : InputEvent) -> void:
	if Tool.Type.DESTROY != _game_state.get_selected_tool() \
		and event.is_action_pressed("bulldoze_tool_shortcut"):
			_game_state.set_selected_tool(Tool.Type.DESTROY)


func bulldose_tile(tile_pos : Vector2, id : int = 1) -> void:
	if not _terrain.is_tile_empty(tile_pos):
		# If the tile is already owned.
		if owner_dict.has(tile_pos):
			# If we own the tile.
			if owner_dict[tile_pos].id == id:
				if is_resource(tile_pos):
					_terrain.set_cellv(tile_pos, Tile.Type.GRASS)
					print("can remove the resource")
				elif is_building(tile_pos):
					_terrain.set_cellv(tile_pos, Tile.Type.DIRT)
					emit_signal("building_destroyed", tile_pos)
				else:
					print("cannot remove the resource")
	
	
func is_resource(tile_pos : Vector2) -> bool:
	return _terrain.get_cellv(tile_pos) == Tile.Type.FOREST or\
		_terrain.get_cellv(tile_pos) == Tile.Type.FARM or\
		_terrain.get_cellv(tile_pos) == Tile.Type.MEADOW or\
		_terrain.get_cellv(tile_pos) == Tile.Type.STONE
		
func is_building(tile_pos : Vector2) -> bool:
	return _terrain.get_cellv(tile_pos) == Tile.Type.LUMBERJACK or\
		_terrain.get_cellv(tile_pos) == Tile.Type.MINE or\
		_terrain.get_cellv(tile_pos) == Tile.Type.POWER_PLANT or\
		_terrain.get_cellv(tile_pos) == Tile.Type.PYLON or\
		_terrain.get_cellv(tile_pos) == Tile.Type.WOOD_REFINERY or\
		_terrain.get_cellv(tile_pos) == Tile.Type.MINERALS_REFINERY or\
		_terrain.get_cellv(tile_pos) == Tile.Type.LUMBER_FACTORY or\
		_terrain.get_cellv(tile_pos) == Tile.Type.METAL_FACTORY or\
		_terrain.get_cellv(tile_pos) == Tile.Type.MINERALS_FACTORY or\
		_terrain.get_cellv(tile_pos) == Tile.Type.WOOD_FACTORY
	
remote func request_bulldoze(tile_pos : Vector2) -> void:
	var _sender_id = get_tree().get_rpc_sender_id()
	
	if owner_dict.has(tile_pos):
		pass


# ------------------------------------------------------------------------------
func _process(_delta):
	if Tool.Type.DESTROY == _game_state.get_selected_tool():
		_place_circle_position()
		set_colour()
	update()


# ------------------------------------------------------------------------------
func _draw():
	if Tool.Type.DESTROY == _game_state.get_selected_tool():
		draw_circle(centre, radius, colour)
	
	
# ------------------------------------------------------------------------------
func _place_circle_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
	var position : Vector2 = _terrain.get_global_position_from_tile(mouse_tile)
	centre = position + Vector2(64, 64)
	
	
# ------------------------------------------------------------------------------
func set_colour() -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
	var player_data_manager = Utility.get_dependency("player_data_manager", self, true)
	if owner_dict.has(mouse_tile):
		var first_id = owner_dict[mouse_tile].id
		var second_id = player_data_manager.local_player_data.id
		if (first_id == second_id and Network.is_online) or first_id == 1:
			colour = CAN_PLACE_COLOUR
	else:
		colour = CANNOT_PLACE_COLOUR
