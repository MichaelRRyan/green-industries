extends "res://addons/gut/test.gd"



const TERRAIN_NAME : String = "Terrain"
const POLLUTION_NAME : String = "Polution_spreading"

const TEST_CELL = Vector2(5, 5)

var GameplayScene = preload("res://scenes/gameplay.tscn")

var _gameplay = null
var _terrain = null


func before_all():
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	# Finds a child node with the terrain name and ensures it's not null.
	_terrain = find_node(TERRAIN_NAME, true, false)
	assert_not_null(_terrain)

func before_each() -> void:
	# Sets the tile type to empty so we can place a building.
	_terrain.set_cellv(TEST_CELL, Tile.Type.DIRT)
	
	# Sets all neighbour cells to grass.
	for neighbour in Utility.get_neighbours(TEST_CELL):
		_terrain.set_cellv(neighbour, Tile.Type.GRASS)


func after_all():
	_gameplay.free()


func test_pollution_spread():
	var spread = find_node(POLLUTION_NAME, false, false)
	#checks the neighbouring cells 
	var neighbours = Utility.get_neighbours(TEST_CELL)
	assert_eq(neighbours.size(), 6)
	
	for neighbour in neighbours:
		
		# Sets a forest tile to the neighbour location.
		_terrain.set_cellv(neighbour, Tile.Type.FOREST)
		
		# Waits a little longer than the harvest time.
		yield(yield_for(0.15), YIELD)
		
		# Checks damage has been done and sets the tile back to grass.
		#assert_true(spread.pollute_cell.has(neighbour))
		_terrain.set_cellv(neighbour, Tile.Type.DIRT)
		
