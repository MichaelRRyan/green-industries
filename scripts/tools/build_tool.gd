extends Node2D

signal building_placed(building, type, owner_id)

onready var _game_state = Utility.get_dependency("game_state", self, true)
onready var _world = Utility.get_dependency("world", self, true)
onready var _terrain = Utility.get_dependency("terrain", self, true)
onready var _buy_tool = Utility.get_dependency("buy_tool", self, true)

var building_type : int = Tile.Type.LUMBERJACK
const CAN_PLACE_COLOUR : Color = Color(0 / 255,165.0 / 255,0,175.0 / 255)
const CANNOT_PLACE_COLOUR : Color = Color(165.0 / 255,0 / 255,0,175.0 / 255)
onready var colour = CAN_PLACE_COLOUR
onready var centre: Vector2 = Vector2(0,0)
var num_tiles = 0.5
var radius = 110 * num_tiles
onready var _preview_building : Sprite = $PreviewBuilding


onready var BuildingScenes = {
	Tile.Type.LUMBERJACK: preload("res://scenes/buildings/lumberjack.tscn"),
	Tile.Type.MINE: preload("res://scenes/buildings/mine.tscn"),
	Tile.Type.FACTORY: preload("res://scenes/factory.tscn"),
	Tile.Type.POWER_PLANT: preload("res://scenes/buildings/power_plant.tscn"),
	Tile.Type.PYLON: preload("res://scenes/buildings/pylon.tscn"),
	Tile.Type.WOOD_REFINERY: null,
	Tile.Type.MINERALS_REFINERY: null,
}


onready var BuildingPreviews = {
	Tile.Type.LUMBERJACK: Rect2(390, 500, 128, 140),
	Tile.Type.MINE: Rect2(520, 500, 120, 140),
	Tile.Type.FACTORY: Rect2(640, 500, 120, 140),
	Tile.Type.POWER_PLANT: Rect2(770, 500, 128, 140),
	Tile.Type.PYLON: Rect2(900, 500, 128, 140),
	Tile.Type.WOOD_REFINERY: Rect2(1040, 500, 128, 128),
	Tile.Type.MINERALS_REFINERY: Rect2(1040, 500, 128, 128),
}


# ------------------------------------------------------------------------------
func set_building_type(type : int) -> void:
	building_type = type
	_preview_building.region_rect = BuildingPreviews[building_type]

remote func request_build(tile_pos: Vector2, _building_type: int) -> void:
	if _terrain.is_tile_empty(tile_pos):			
		_terrain.set_cellv(tile_pos, _building_type)
		var building = null
		var factory_pattern = null
		if building_type == Tile.Type.WOOD_REFINERY:
			factory_pattern = WoodRefineryFactory.new()
		elif building_type == Tile.Type.MINERALS_REFINERY:
			factory_pattern = MineralsRefineryFactory.new()
		else:
			building = BuildingScenes[building_type].instance()
		if factory_pattern != null:
			building = factory_pattern.generate_scene()		
		#sending the other clients where the building was placed
		rpc("place_building_remote", tile_pos, _building_type)
		building.set_network_master(get_tree().get_network_unique_id())
			
		# Places the building uniformly on a tile corner.
		building.position = (_terrain.get_global_position_from_tile(tile_pos) +
			_terrain.tile_size * 0.5)
		
		_world.add_child(building)
		emit_signal("building_placed", building, _building_type, get_tree().get_rpc_sender_id())


# ------------------------------------------------------------------------------
func place_building(tile_pos : Vector2) -> bool:
	if Network.is_client():
		rpc_id(1, "request_build", tile_pos, building_type)
		return true
	if _terrain.is_tile_empty(tile_pos):			
		_terrain.set_cellv(tile_pos, building_type)
		var building = null
		var factory_pattern = null
		if building_type == Tile.Type.WOOD_REFINERY:
			factory_pattern = WoodRefineryFactory.new()
		elif building_type == Tile.Type.MINERALS_REFINERY:
			factory_pattern = MineralsRefineryFactory.new()
		else:
			building = BuildingScenes[building_type].instance()
		if factory_pattern != null:
			building = factory_pattern.generate_scene()
		#sending the other clients where the building was placed
		if Network.is_online:
			rpc("place_building_remote", tile_pos, building_type)
			building.set_network_master(get_tree().get_network_unique_id())
			
		# Places the building uniformly on a tile corner.
		building.position = (_terrain.get_global_position_from_tile(tile_pos) +
			_terrain.tile_size * 0.5)
		
		_world.add_child(building)
		emit_signal("building_placed", building, building_type, get_tree().get_network_unique_id())
		
		return true
	return false

remote func place_building_remote(tile_pos : Vector2, type : int) -> void:
	_terrain.set_cellv(tile_pos, type)
	var building = null
	var factory_pattern = null
	if building_type == Tile.Type.WOOD_REFINERY:
		factory_pattern = WoodRefineryFactory.new()
	elif building_type == Tile.Type.MINERALS_REFINERY:
		factory_pattern = MineralsRefineryFactory.new()
	else:
		building = BuildingScenes[building_type].instance()
	if factory_pattern != null:
		building = factory_pattern.generate_scene()
	building.set_network_master(get_tree().get_rpc_sender_id())
	# Places the building uniformly on a tile corner.
	building.position = (_terrain.get_global_position_from_tile(tile_pos) +
		_terrain.tile_size * 0.5)
		
	_world.add_child(building)
	#emit_signal("building_placed", building, type, get_tree().get_network_unique_id())

# ------------------------------------------------------------------------------
func _ready() -> void:
	_world = Utility.get_dependency("world", self, true)
	_terrain = Utility.get_dependency("terrain", self, true)
	_buy_tool = Utility.get_dependency("buy_tool", self, true)
	_preview_building.self_modulate = Color(1, 1, 1, 0.4)
	_preview_building.region_rect = BuildingPreviews[building_type]


# ------------------------------------------------------------------------------
func _unhandled_input(event : InputEvent) -> void:
	if Tool.Type.BUILD == _game_state.get_selected_tool():
		if event.is_action_pressed("select"):
			# Needs to be extended to get the selection instead of the mouse pos.
			var mouse_pos = get_global_mouse_position()
			var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
			if _buy_tool.owner_dict.has(mouse_tile):
				if (Network.state == Network.State.SOLO and _buy_tool.owner_dict[mouse_tile].id == 1) \
					or _buy_tool.owner_dict[mouse_tile].id == get_tree().get_network_unique_id():
						var _success = place_building(mouse_tile)
			
			else:
				buy_tile_and_place_building(mouse_tile)
		
	
		if event.is_action_pressed("select_1"):
			building_type = Tile.Type.LUMBERJACK
			_preview_building.region_rect = BuildingPreviews[building_type]
			#_preview_building.region_rect = Rect2(390, 500, 128, 140)
		
		if event.is_action_pressed("select_2"):
			building_type = Tile.Type.MINE
			_preview_building.region_rect = BuildingPreviews[building_type]
		
		if event.is_action_pressed("select_3"):
			building_type = Tile.Type.FACTORY
			_preview_building.region_rect = BuildingPreviews[building_type]
			
		if event.is_action_pressed("select_4"):
			building_type = Tile.Type.POWER_PLANT
			_preview_building.region_rect = BuildingPreviews[building_type]
		
		if event.is_action_pressed("select_5"):
			building_type = Tile.Type.PYLON
			_preview_building.region_rect = BuildingPreviews[building_type]
			
		if event.is_action_pressed("select_6"):
			building_type = Tile.Type.WOOD_REFINERY
			_preview_building.region_rect = BuildingPreviews[building_type]
			
		if event.is_action_pressed("select_7"):
			building_type = Tile.Type.MINERALS_REFINERY
			_preview_building.region_rect = BuildingPreviews[building_type]
			
	elif event.is_action_pressed("build_tool_shortcut"):
		_game_state.set_selected_tool(Tool.Type.BUILD)

# ------------------------------------------------------------------------------
func buy_tile_and_place_building(tile_pos : Vector2) -> void:
	if _buy_tool.check_availble(tile_pos) and _terrain.is_tile_empty(tile_pos):
			_buy_tool.buy_tile(tile_pos)
			var _r = place_building(tile_pos)


func _process(_delta):
	if Tool.Type.BUILD == _game_state.get_selected_tool():
		_place_circle_position()
		set_colour()
		_preview_building.visible = true
		_preview_building.position = centre
	else:
		_preview_building.visible = false
	update()


func _draw():
	if Tool.Type.BUILD == _game_state.get_selected_tool():
		draw_circle(centre, radius, colour)
	
	
func _place_circle_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
	var position : Vector2 = _terrain.get_global_position_from_tile(mouse_tile)
	centre = position + Vector2(64, 64)
	
	
func set_colour() -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_tile : Vector2 = _terrain.get_tile_from_global_position(mouse_pos)
	if _terrain.is_tile_empty(mouse_tile):
		colour = CAN_PLACE_COLOUR
	else:
		colour = CANNOT_PLACE_COLOUR
