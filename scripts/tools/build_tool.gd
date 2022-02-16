extends ToolInterfaces.BuildTool

signal building_placed(building, type, owner_id)

onready var _game_state = Utility.get_dependency("game_state", self, true)
onready var _world = Utility.get_dependency("world", self, true)
onready var _terrain = Utility.get_dependency("terrain", self, true)
onready var _buy_tool = Utility.get_dependency("buy_tool", self, true)
onready var _networked_players = Utility.get_dependency("player_data_manager", self, true).networked_players

var _building_type : int = Tile.Type.LUMBERJACK
const CAN_PLACE_COLOUR : Color = Color(0 / 255,165.0 / 255,0,175.0 / 255)
const CANNOT_PLACE_COLOUR : Color = Color(165.0 / 255,0 / 255,0,175.0 / 255)
onready var colour = CAN_PLACE_COLOUR
onready var centre: Vector2 = Vector2(0,0)
var num_tiles = 0.5
var radius = 110 * num_tiles
onready var _preview_building : Sprite = $PreviewBuilding
var data = null
var resource_manager = null


onready var BuildingScenes = {
	Tile.Type.LUMBERJACK: preload("res://scripts/classes/wood_harvester_factory.gd"),
	Tile.Type.MINE: preload("res://scripts/classes/minerals_harvester_factory.gd"),
	Tile.Type.LUMBER_FACTORY: preload("res://scripts/classes/lumber_factory_factory.gd"),
	Tile.Type.METAL_FACTORY: preload("res://scripts/classes/metal_factory_factory.gd"),
	Tile.Type.MINERALS_FACTORY: preload("res://scripts/classes/minerals_factory_factory.gd"),
	Tile.Type.WOOD_FACTORY: preload("res://scripts/classes/wood_factory_factory.gd"),
	Tile.Type.POWER_PLANT: preload("res://scripts/classes/power_plant_factory.gd"),
	Tile.Type.PYLON: preload("res://scripts/classes/pylon_factory.gd"),
	Tile.Type.WOOD_REFINERY: preload("res://scripts/classes/wood_refinery_factory.gd"),
	Tile.Type.MINERALS_REFINERY: preload("res://scripts/classes/minerals_refinery_factory_pattern.gd"),
}


onready var BuildingPreviews = {
	Tile.Type.LUMBERJACK: Rect2(390, 500, 128, 140),
	Tile.Type.MINE: Rect2(520, 500, 120, 140),
	Tile.Type.LUMBER_FACTORY: Rect2(640, 510, 120, 140),
	Tile.Type.METAL_FACTORY: Rect2(640, 510, 120, 140),
	Tile.Type.MINERALS_FACTORY: Rect2(640, 510, 120, 140),
	Tile.Type.WOOD_FACTORY: Rect2(640, 510, 120, 140),
	Tile.Type.POWER_PLANT: Rect2(770, 500, 128, 140),
	Tile.Type.PYLON: Rect2(900, 500, 128, 140),
	Tile.Type.WOOD_REFINERY: Rect2(1040, 500, 128, 128),
	Tile.Type.MINERALS_REFINERY: Rect2(1040, 500, 128, 128),
}


# ------------------------------------------------------------------------------
func set_building_type(type : int) -> void:
	_building_type = type
	_preview_building.region_rect = BuildingPreviews[_building_type]
	
	
# ------------------------------------------------------------------------------
func get_building_type() -> int:
	return _building_type


# ------------------------------------------------------------------------------
func _get_factory_pattern(type : int) -> Node2D:
	var factory_pattern = BuildingScenes[type].new()
	return factory_pattern


# ------------------------------------------------------------------------------
func place_building(tile_pos : Vector2, id : int = 1, building_type: int = -1) -> void:
	if _terrain.is_tile_empty(tile_pos):
		
		# If the tile is already owned.
		if _buy_tool.owner_dict.has(tile_pos):
			
			# If we own the tile.
			if _buy_tool.owner_dict[tile_pos].id == id:
				if building_type == -1:
					buy_and_place_building(tile_pos, _building_type, id)
				else:
					buy_and_place_building(tile_pos, building_type, id)
					
		else:
			if building_type == -1:
				buy_tile_and_place_building(tile_pos, _building_type, id)
			else:
				buy_tile_and_place_building(tile_pos, building_type, id)


# ------------------------------------------------------------------------------
func buy_and_place_building(tile_pos : Vector2, building_type : int, player_id : int = 1) -> void:

	var building = set_building(tile_pos, building_type, \
		_networked_players[player_id]._inventory)
				
	# Tells the other clients to place a building.
	if Network.is_online:
		rpc("place_building_remote", tile_pos, building_type)
	
	emit_signal("building_placed", building, building_type, player_id)


# ------------------------------------------------------------------------------
remote func request_place_building(tile_pos: Vector2, requested_type: int) -> void:
	var sender_id = get_tree().get_rpc_sender_id()
	
	if _terrain.is_tile_empty(tile_pos):
		
		if _buy_tool.owner_dict.has(tile_pos):
			if _buy_tool.owner_dict[tile_pos].id == sender_id:

					var building = set_building(tile_pos, requested_type, \
						_networked_players[sender_id]._inventory)
					
					# Tells the other clients to place a building.
					rpc("place_building_remote", tile_pos, requested_type)
					
					emit_signal("building_placed", building, requested_type, sender_id)
		
		else:
			buy_tile_and_place_building(tile_pos, requested_type, sender_id)


# ------------------------------------------------------------------------------
remote func place_building_remote(tile_pos : Vector2, type : int) -> void:
	var _building = set_building(tile_pos, type)


# ------------------------------------------------------------------------------
func buy_tile_and_place_building(tile_pos : Vector2, type : int, player_id : int = 1) -> void:
	if _buy_tool.has_enough_money_for_tile(tile_pos, player_id) \
		and _get_factory_pattern(type).is_able_build(data._inventory):
			_buy_tool.buy_tile(tile_pos, player_id)
			buy_and_place_building(tile_pos, type, player_id)


# ------------------------------------------------------------------------------
func set_building(tile_pos : Vector2, building_type : int, inventory : Inventory = null) -> Node2D:
	var building = null

	# If an inventory is passed, uses it to buy the building, otherwise just generates a building.
	if inventory:
		building = _get_factory_pattern(building_type).generate_scene(inventory)
		
		# If no building could be placed, returns null.
		if building == null:
			print("Cannot place building")
			return null
	else:
		building = _get_factory_pattern(building_type).generate_bought_scene()
		
	_terrain.set_cellv(tile_pos, building_type)
	
	# Places the building in the tile centre.
	building.position = (_terrain.get_global_position_from_tile(tile_pos) +
		_terrain.tile_size * 0.5)
	
	_world.add_child(building)
	
	return building
	

# ------------------------------------------------------------------------------
func _ready() -> void:
	_preview_building.self_modulate = Color(1, 1, 1, 0.4)
	_preview_building.region_rect = BuildingPreviews[_building_type]
	resource_manager = Utility.get_dependency("resource_manager", self, true)
	data = Utility.get_dependency("player_data_manager", self, true).local_player_data


# ------------------------------------------------------------------------------
func _unhandled_input(event : InputEvent) -> void:
	if Tool.Type.BUILD == _game_state.get_selected_tool():

		if event.is_action_pressed("select_1"):
			set_building_type(Tile.Type.LUMBERJACK)

		elif event.is_action_pressed("select_2"):
			set_building_type(Tile.Type.MINE)
		
		elif event.is_action_pressed("select_3"):
			set_building_type(Tile.Type.LUMBER_FACTORY)
		
		elif event.is_action_pressed("select_4"):
			set_building_type(Tile.Type.METAL_FACTORY)
			
		elif event.is_action_pressed("select_5"):
			set_building_type(Tile.Type.MINERALS_FACTORY)
			
		elif event.is_action_pressed("select_6"):
			set_building_type(Tile.Type.WOOD_FACTORY)
				
		elif event.is_action_pressed("select_7"):
			set_building_type(Tile.Type.POWER_PLANT)
		
		elif event.is_action_pressed("select_8"):
			set_building_type(Tile.Type.PYLON)
			
		elif event.is_action_pressed("select_9"):
			set_building_type(Tile.Type.WOOD_REFINERY)
			
		elif event.is_action_pressed("select_0"):
			set_building_type(Tile.Type.MINERALS_REFINERY)
			
	elif event.is_action_pressed("build_tool_shortcut"):
		_game_state.set_selected_tool(Tool.Type.BUILD)


# ------------------------------------------------------------------------------
func _process(_delta):
	if Tool.Type.BUILD == _game_state.get_selected_tool():
		_place_circle_position()
		set_colour()
		_preview_building.visible = true
		_preview_building.position = centre
	else:
		_preview_building.visible = false
	update()


# ------------------------------------------------------------------------------
func _draw():
	if Tool.Type.BUILD == _game_state.get_selected_tool():
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
	if _terrain.is_tile_empty(mouse_tile):
		colour = CAN_PLACE_COLOUR
	else:
		colour = CANNOT_PLACE_COLOUR


# ------------------------------------------------------------------------------
