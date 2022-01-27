extends Node2D

onready var tile_map : TileMap = $TileMap
onready var factory_prefab = preload("res://scenes/factory.tscn")

var water : int = 2
var factory : int = 3
var offset : Vector2 = Vector2(56, 64)

# ------------------------------------------------------------------------------
func _ready():
	for x in range(WorldTiles.data.size()):
		for y in range(WorldTiles.data[x].size()):
			tile_map.set_cell(x, y, WorldTiles.data[x][y])

func on_click(mouse_position: Vector2):
	var tile_clicked: Vector2 = tile_map.world_to_map(mouse_position)
	var tile = tile_map.get_cell(tile_clicked.x, tile_clicked.y)
	if tile != factory and tile != water:
		tile_map.set_cell(tile_clicked.x, tile_clicked.y, factory)
		var instance = factory_prefab.instance()
		instance.position = tile_map.map_to_world(tile_clicked) + offset	
		get_parent().add_child(instance)
# ------------------------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("place_factory"):
		self.on_click(event.position)
