extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const MINE_NAME : String = "Mine"

# The cell in the tile map where the test will take place.
const TEST_CELL = Vector2(0, 0)

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _build_tool = null


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


# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()


# ------------------------------------------------------------------------------
func before_each() -> void:
	# Sets the tile type to empty so we can place a building.
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)


# ------------------------------------------------------------------------------
func test_lumberjack_can_be_placed() -> void:
	# Selects the lumberjack building.
	_build_tool.set_building_type(Tile.Type.LUMBERJACK)
	
	# Places the building and check that it has been placed.
	_build_tool.place_building(TEST_CELL)
	assert_eq(Tile.Type.LUMBERJACK, _terrain.get_cellv(TEST_CELL))
	
	# Checks if a lumberjack instance can be found.
	var lumberjack = find_node(LUMBERJACK_NAME, true, false)
	assert_not_null(lumberjack)
	

# ------------------------------------------------------------------------------
func test_mine_can_be_placed() -> void:
	# Selects the mine building.
	_build_tool.set_building_type(Tile.Type.MINE)
	
	# Places the building and check that it has been placed.
	_build_tool.place_building(TEST_CELL)
	assert_eq(Tile.Type.MINE, _terrain.get_cellv(TEST_CELL))
	
	# Checks if a mine instance can be found.
	var mine = find_node(MINE_NAME, true, false)
	assert_not_null(mine)
	

# ------------------------------------------------------------------------------
