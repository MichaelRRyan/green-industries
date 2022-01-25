extends Node2D

onready var tile_map : TileMap = $TileMap


# ------------------------------------------------------------------------------
func _ready():
	for x in range(WorldTiles.data.size()):
		for y in range(WorldTiles.data[x].size()):
			tile_map.set_cell(x, y, WorldTiles.data[x][y])


# ------------------------------------------------------------------------------
