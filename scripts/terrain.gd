extends Node2D
tool 
onready var tile_map : TileMap = $TileMap
onready var factory_prefab = preload("res://scenes/factory.tscn")

enum TileType {
	NONE = -1,
	EMPTY = 0,
	GRASS = 1,
	WATER = 2,
	FACTORY = 3
}

var offset : Vector2 = Vector2(56, 64)
var damage_dict = {}

# ------------------------------------------------------------------------------
func _ready():
	for x in range($WorldGenerator.map.size()):
		for y in range($WorldGenerator.map[x].size()):
			tile_map.set_cell(x, y, $WorldGenerator.map[x][y])
# ------------------------------------------------------------------------------

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		$WorldGenerator.generate_world()
		
		for x in range($WorldGenerator.map.size()):
			for y in range($WorldGenerator.map[x].size()):
				$TileMap.set_cell(x, y, $WorldGenerator.map[x][y])

func on_click(mouse_position: Vector2):
	var tile_clicked: Vector2 = tile_map.world_to_map(mouse_position)
	var tile = tile_map.get_cell(tile_clicked.x, tile_clicked.y)
	if tile == TileType.GRASS:
		tile_map.set_cell(tile_clicked.x, tile_clicked.y, TileType.FACTORY)
		var instance = factory_prefab.instance()
		instance.position = tile_map.map_to_world(tile_clicked) + offset	
		get_parent().add_child(instance)
	
	if tile != TileType.GRASS and tile != TileType.WATER and tile != TileType.FACTORY:
		if !damage_dict.has(tile_clicked):
			damage_dict[tile_clicked] = { 
				health = 9,
				label = Label.new(),
			}
			var tile_data = damage_dict[tile_clicked]
			add_child(tile_data.label)
			tile_data.label.rect_position = tile_map.map_to_world(tile_clicked) + offset
			tile_data.label.text = str(tile_data.health)
			
		else:
			var tile_data = damage_dict[tile_clicked]
			tile_data.health -= 1
			tile_data.label.text = str(tile_data.health)
			if tile_data.health == 0:
				tile_map.set_cell(tile_clicked.x, tile_clicked.y, TileType.GRASS)
				tile_data.label.queue_free()
				damage_dict.erase(tile_clicked)
	

func _input(event):
	if event.is_action_pressed("place_factory"):
		self.on_click(event.position)
