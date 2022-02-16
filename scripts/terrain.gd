extends Node2D

tool

export var _clear = false setget _set_clear, _get_clear

var tile_size : Vector2  = Vector2.ZERO
var l=10
var test = 0
onready var tile_map : TileMap = $TileMap
onready var resources = 100
var offset : Vector2 = Vector2(68, 64)
var damage_dict = {health = 9}
var _wood_resource = null
var _minerals_resource = null
onready var event_triggers = Utility.get_dependency("event_triggers", self, true)
onready var owner_dict = Utility.get_dependency("player_data_manager", self, true).owner_dict

# ------------------------------------------------------------------------------
# Will be used to allow for more empty tiles to be added later (e.g. dirt).
func is_tile_empty(tile : Vector2) -> bool:
	var type = tile_map.get_cellv(tile)
	return type == Tile.Type.GRASS

# ------------------------------------------------------------------------------
# This method will later be extended to account for the hexagonal shape.
func get_tile_from_global_position(pos : Vector2) -> Vector2:
	return tile_map.world_to_map(pos)


# ------------------------------------------------------------------------------
# This method will later be extended to account for the hexagonal shape.
func get_global_position_from_tile(tile : Vector2) -> Vector2:
	return tile_map.map_to_world(tile)


# ------------------------------------------------------------------------------
# Propogating the method out from TileMap.
func set_cellv(cell : Vector2, type : int) -> void:
	tile_map.set_cellv(cell, type)
	
	# If the tile was damaged, remove damage info.
	if damage_dict.has(cell):
		_remove_damage_info(cell)


# ------------------------------------------------------------------------------
# Propogating the method out from TileMap.
func get_cellv(cell : Vector2) -> int:
	return tile_map.get_cellv(cell)


# ------------------------------------------------------------------------------
# This method should be refactored in the future to remove the hardcoding.
func harvest_cell(cell : Vector2) -> ResourceType:
	var type = tile_map.get_cellv(cell)
	
	if type == Tile.Type.FOREST:
		_damage_cell(cell)
		return _wood_resource
		
	elif type == Tile.Type.STONE:
		_damage_cell(cell)
		return _minerals_resource
	
	return null


# ------------------------------------------------------------------------------
func _set_clear(_value : bool) -> void:
	$TileMap.clear()


# ------------------------------------------------------------------------------
func _get_clear() -> bool:
	return false


# ------------------------------------------------------------------------------
func _ready() -> void:
	# If not running in the editor.
	if not Engine.editor_hint:
		# Attempts to get the resource manager and gets the resource types.
		var resource_manager = Utility.get_dependency("resource_manager", self, true)
		_wood_resource = resource_manager.get_resource_type_by_name("wood")
		_minerals_resource = resource_manager.get_resource_type_by_name("minerals")
		
		if not Network.is_client():
			randomize()
			TerrainData.noise_seed = randi()
			
		$WorldGenerator.generate_world()


# ------------------------------------------------------------------------------
func _on_WorldGenerator_world_generated(terrain_tiles):
	tile_size = offset * 2.0 # TEMP
	for x in range(terrain_tiles.size()):
		for y in range(terrain_tiles[x].size()):
			$TileMap.set_cell(x, y, terrain_tiles[x][y])
	
	if not Engine.editor_hint:
		$PollutionSpreading.get_tile_map(tile_map)


# ------------------------------------------------------------------------------
remote func _damage_cell(cell : Vector2, remote_call: bool = false) -> void:
	if not remote_call and Network.is_online:
		rpc("_damage_cell", cell, true)
	
	Pollution.tree_pollution += 1
	
	if !damage_dict.has(cell):
		damage_dict[cell] = { 
			health = 9,
			label = Label.new(),
		}
		
		var tile_data = damage_dict[cell]
		$PollutionSpreading.add_to_polluted_dict(cell)#gets what cell is currently being harvasted 
		add_child(tile_data.label)
		tile_data.label.rect_position = tile_map.map_to_world(cell) + offset
		tile_data.label.text = str(tile_data.health)
	else:
		var tile_data = damage_dict[cell]
		tile_data.health -= 1
		#to get the harvasted tiles health, and if it is 5 start polluting ^^
		$PollutionSpreading.polluted_dict.health = tile_data.health 
		l=tile_data.health
		tile_data.label.text = str(tile_data.health)
		if tile_data.health == 5:
			#starts pollution ^^----------------------
			$PollutionSpreading.pollute_cell(cell)
			$PollutionSpreading.active_pollution = true
			$PollutionSpreading.get_active_pollution($PollutionSpreading.active_pollution)
			
		if tile_data.health == 0:
			if tile_map.get_cellv(cell) == Tile.Type.FOREST:
				event_triggers.wood_tile_depleted()
			elif tile_map.get_cellv(cell) == Tile.Type.STONE:
				event_triggers.stone_tile_depleted()
			tile_map.set_cellv(cell, Tile.Type.GRASS)
			_remove_damage_info(cell)
			

# ------------------------------------------------------------------------------
func _remove_damage_info(cell : Vector2) -> void:
	damage_dict[cell].label.queue_free()
	damage_dict.erase(cell)
	

# ------------------------------------------------------------------------------
func _input(event) -> void:
	# If not running in the editor.
	if not Engine.editor_hint:
		if event.is_action_pressed("place_factory"):
			self.on_click(get_global_mouse_position())

	
# ------------------------------------------------------------------------------	
func on_click(mouse_position: Vector2) -> void:
	var tile_clicked: Vector2 = tile_map.world_to_map(mouse_position)
	var tile = tile_map.get_cellv(tile_clicked)

	if tile == Tile.Type.STONE or tile == Tile.Type.FOREST:
		_damage_cell(tile_clicked)
					
# ------------------------------------------------------------------------------
func get_tile_clicked(position : Vector2) -> int:
	var tile_clicked: Vector2 = tile_map.world_to_map(position)
	var tile = tile_map.get_cellv(tile_clicked)
	return tile
