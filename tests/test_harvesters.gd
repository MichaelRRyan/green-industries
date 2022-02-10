extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const MINE_NAME : String = "Mine"
const BUY_TOOL_NAME : String = "BuyTool"

# The cell in the tile map where the test will take place.
const TEST_CELL = Vector2(5, 5)

var GameplayScene = preload("res://scenes/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _build_tool = null
var _buy_tool = null

# ------------------------------------------------------------------------------
func before_all() -> void:
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	# Finds a child node with the terrain name and ensures it's not null.
	_terrain = find_node(TERRAIN_NAME, true, false)
	assert_not_null(_terrain)
	
	# Finds a child node with the build tool name and ensures it's not null.
	_build_tool = find_node(BUILD_TOOL_NAME, true, false)
	assert_not_null(_build_tool)
	
	_buy_tool = find_node(BUY_TOOL_NAME, true, false)
	assert_not_null(_buy_tool)

# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()
	
	
# ------------------------------------------------------------------------------
func before_each() -> void:
	# Sets the tile type to empty so we can place a building.
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	
	# Sets all neighbour cells to grass.
	for neighbour in Utility.get_neighbours(TEST_CELL):
		_terrain.set_cellv(neighbour, Tile.Type.GRASS)


# ------------------------------------------------------------------------------
func test_lumberjack_harvests_wood() -> void:
	
	# Places the lumberjack building.
	_build_tool.set_building_type(Tile.Type.LUMBERJACK)
	_build_tool.place_building(TEST_CELL)
	
	# Finds and modifies the lumberjack to harvest faster.
	var lumberjack = find_node(LUMBERJACK_NAME, true, false)
	lumberjack.set_seconds_per_harvest(0.1)
	
	# Gets the lumberjack's neighbours and makes sure there's 6 of them.
	var neighbours = Utility.get_neighbours(TEST_CELL)
	assert_eq(neighbours.size(), 6)
	
	# Loops through all the lumberjack's neighbours.
	for neighbour in neighbours:
		_buy_tool.buy_tile(neighbour)
		# Sets a forest tile to the neighbour location.
		_terrain.set_cellv(neighbour, Tile.Type.FOREST)
		
		# Waits a little longer than the harvest time.
		yield(yield_for(0.15), YIELD)
		
		# Checks damage has been done and sets the tile back to grass.
		assert_true(_terrain.damage_dict.has(neighbour))
		_terrain.set_cellv(neighbour, Tile.Type.GRASS)
		

# ------------------------------------------------------------------------------
func test_mine_harvests_minerals() -> void:
	
	# Places the mine building.
	_build_tool.set_building_type(Tile.Type.MINE)
	_build_tool.place_building(TEST_CELL)
	
	# Finds and modifies the mine to harvest faster.
	var mine = find_node(MINE_NAME, true, false)
	mine.set_seconds_per_harvest(0.1)
	
	# Gets the mine's neighbours and makes sure there's 6 of them.
	var neighbours = Utility.get_neighbours(TEST_CELL)
	assert_eq(neighbours.size(), 6)
	
	# Loops through all the mine's neighbours.
	for neighbour in neighbours:
		_buy_tool.buy_tile(neighbour)
		# Sets a stone tile to the neighbour location.
		_terrain.set_cellv(neighbour, Tile.Type.STONE)
		
		# Waits a little longer than the harvest time.
		yield(yield_for(0.15), YIELD)
		
		# Checks damage has been done and sets the tile back to grass.
		assert_true(_terrain.damage_dict.has(neighbour))
		_terrain.set_cellv(neighbour, Tile.Type.GRASS)
		

# ------------------------------------------------------------------------------
