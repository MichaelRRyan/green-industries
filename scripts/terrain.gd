extends Node2D
tool 

var tile_size : Vector2  = Vector2.ZERO

onready var tile_map : TileMap = $TileMap
onready var factory_prefab = preload("res://scenes/factory.tscn")
onready var factory_pattern = preload("res://scenes/factory_pattern.tscn").instance()
onready var resources = 100

var offset : Vector2 = Vector2(56, 64)
var damage_dict = {}

var _wood_resource = null
var _minerals_resource = null


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
func _ready() -> void:
	# If not running in the editor.
	if not Engine.editor_hint:
		# Attempts to get the resource manager and gets the resource types.
		var resource_manager = Utility.get_dependency("resource_manager", self, true)
		_wood_resource = resource_manager.get_resource_type_by_name("wood")
		_minerals_resource = resource_manager.get_resource_type_by_name("minerals")
	
	tile_size = offset * 2.0 # TEMP
	
	for x in range($WorldGenerator.map.size()):
		for y in range($WorldGenerator.map[x].size()):
			tile_map.set_cell(x, y, $WorldGenerator.map[x][y])

func _process(_delta):
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var tile_clicked: Vector2 = tile_map.world_to_map(mouse_position)
	
	if Input.is_action_just_pressed("ui_accept"):
		$WorldGenerator.generate_world()

# ------------------------------------------------------------------------------
func _damage_cell(cell : Vector2) -> void:
	if !damage_dict.has(cell):
		damage_dict[cell] = { 
			health = 9,
			label = Label.new(),
		}
		var tile_data = damage_dict[cell]
		add_child(tile_data.label)
		tile_data.label.rect_position = tile_map.map_to_world(cell) + offset
		tile_data.label.text = str(tile_data.health)
	else:
		var tile_data = damage_dict[cell]
		tile_data.health -= 1
		tile_data.label.text = str(tile_data.health)
		if tile_data.health == 0:
			tile_map.set_cellv(cell, Tile.Type.GRASS)
			_remove_damage_info(cell)


# ------------------------------------------------------------------------------
func _remove_damage_info(cell : Vector2) -> void:
	damage_dict[cell].label.queue_free()
	damage_dict.erase(cell)


# ------------------------------------------------------------------------------
func _input(event) -> void:
	if event.is_action_pressed("place_factory"):
		self.on_click(get_global_mouse_position())
	elif event.is_action_pressed("place_power_plant"):
		self.place_power_plant(get_global_mouse_position(),\
		 	get_tile_clicked(get_global_mouse_position()))
	
	if event.is_action_pressed("ui_home"):
		$WorldGenerator.generate_world()
		for x in range($WorldGenerator.map.size()):
			for y in range($WorldGenerator.map[x].size()):
				$TileMap.set_cell(x, y, $WorldGenerator.map[x][y])
				
func on_click(mouse_position: Vector2):
	var tile_clicked: Vector2 = tile_map.world_to_map(mouse_position)
	var tile = tile_map.get_cell(tile_clicked.x, tile_clicked.y)

		
	if tile == Tile.Type.STONE or tile == Tile.Type.FOREST:
		_damage_cell(tile_clicked)
				
func place_power_plant(mouse_position: Vector2, tile):
	if tile == Tile.Type.GRASS:
		var plant = factory_pattern.create_coal_power_plant(resources, 2)
		if plant != null:
			resources -= factory_pattern.resources_required_coal_power_plant()
			var tile_clicked: Vector2 = tile_map.world_to_map(mouse_position)
			tile_map.set_cell(tile_clicked.x, tile_clicked.y, Tile.Type.POWER_PLANT)
			plant.position = tile_map.map_to_world(tile_clicked) + offset	
			get_parent().add_child(plant)

func get_tile_clicked(position):
	var tile_clicked: Vector2 = tile_map.world_to_map(position)
	var tile = tile_map.get_cell(tile_clicked.x, tile_clicked.y)
	return tile
	
