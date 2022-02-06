extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const PLAYER_INVENTORY_NAME : String = "PlayerInventory"
const RESOURCE_MANAGER_NAME = "ResourceManager"
const WOOD_RESOURCE_NAME = "wood"

# The cell in the tile map where the test will take place.
const TEST_CELL = Vector2(5, 5)

var GameplayScene = preload("res://scenes/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _build_tool = null
var _player_inventory = null
var _resource_manager = null


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
	
	# Finds a child node with the player inventory name and ensures it's not null.
	_player_inventory = find_node(PLAYER_INVENTORY_NAME, true, false)
	assert_not_null(_player_inventory)
	
	# Tries to find the resource manager and ensures it's not null.
	_resource_manager = find_node(RESOURCE_MANAGER_NAME, true, false)
	assert_not_null(_resource_manager)
	
	
# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()
	
	
# ------------------------------------------------------------------------------
func test_player_gains_resources() -> void:
	
	# Sets the tile type to empty so we can place a building.
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	
	# Places the lumberjack building.
	_build_tool.set_building_type(Tile.Type.LUMBERJACK)
	_build_tool.place_building(TEST_CELL)
	
	# Finds and modifies the lumberjack to harvest faster.
	var lumberjack = find_node(LUMBERJACK_NAME, true, false)
	lumberjack.set_seconds_per_harvest(0.1)
	
	# Gets the lumberjack's neighbours and sets the first to a forest.
	var neighbours = Utility.get_neighbours(TEST_CELL)
	_terrain.set_cellv(neighbours[0], Tile.Type.FOREST)
	
	# Waits a little longer than the harvest time.
	yield(yield_for(0.15), YIELD)
	
	# Tries to get the resource by name and ensures it's not null.
	var wood = _resource_manager.get_resource_type_by_name(WOOD_RESOURCE_NAME)
	assert_not_null(wood)
	
	# Checks that the player's inventory has one wood resource.
	assert_true(_player_inventory._resources.has(wood))
	assert_eq(_player_inventory._resources[wood], 1)


# ------------------------------------------------------------------------------
