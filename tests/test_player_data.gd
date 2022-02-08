extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const PLAYER_DATA_NAME : String = "PlayerData"
const RESOURCE_MANAGER_NAME = "ResourceManager"
const WOOD_RESOURCE_NAME = "wood"

# The cell in the tile map where the test will take place.
const TEST_CELL = Vector2(5, 5)

var GameplayScene = preload("res://scenes/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _build_tool = null
var _player_data = null
var _resource_manager = null
var _inventory : Inventory = null


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
	
	# Finds a child node with the player data name and ensures it's not null.
	_player_data = find_node(PLAYER_DATA_NAME, true, false)
	assert_not_null(_player_data)
	
	# Gets a the player data's inventory and ensures it's not null.
	_inventory = _player_data._inventory
	assert_not_null(_inventory)
	
	# Tries to find the resource manager and ensures it's not null.
	_resource_manager = find_node(RESOURCE_MANAGER_NAME, true, false)
	assert_not_null(_resource_manager)
	
	
# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()
	
	
# ------------------------------------------------------------------------------
func before_each() -> void:
	_inventory.clear()


# ------------------------------------------------------------------------------
func test_player_has_inventory() -> void:
	# Checks the inventory exists and is an object.
	assert_not_null(_inventory)
	assert_typeof(_inventory, TYPE_OBJECT)
	
	# Checks the money exists and is a float.
	assert_not_null(_inventory._money)
	assert_typeof(_inventory._money, TYPE_REAL)
	
	# Checks the resources container exists and is a dictionary.
	assert_not_null(_inventory._resources)
	assert_typeof(_inventory._resources, TYPE_DICTIONARY)
	
	
# ------------------------------------------------------------------------------
func test_inventory_money_methods() -> void:
	
	
	_inventory.set_money(100)
	assert_eq(_inventory._money, 100)
	
	_inventory.change_money(-50)
	assert_eq(_inventory._money, 50)
	
	assert_eq(_inventory._money, _inventory.get_money())


# ------------------------------------------------------------------------------
func test_inventory_resource_methods() -> void:
	# Tries to get the resource by name and ensures it's not null.
	var wood = _resource_manager.get_resource_type_by_name(WOOD_RESOURCE_NAME)
	assert_not_null(wood)
	
	# Adds 5 resources and checks they have been added.
	_inventory.add_resources(wood, 5)
	assert_eq(_inventory.get_quantity(wood), 5)
	
	# Adds 10 more resources and checks they have been added.
	_inventory.add_resources(wood, 10)
	assert_eq(_inventory.get_quantity(wood), 15)
	
	# Removes 5 resources, checks it was successful, and checks the quantity has
	#	changed.
	var success = _inventory.remove_resources(wood, 5)
	assert_eq(success, true)
	assert_eq(_inventory.get_quantity(wood), 10)
	
	# Tries to remove more resources than exists, checks the method failed and
	#	checks the quantity has not changed.
	success = _inventory.remove_resources(wood, 50)
	assert_eq(success, false)
	assert_eq(_inventory.get_quantity(wood), 10)
	

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
	assert_eq(_inventory.get_quantity(wood), 1)


# ------------------------------------------------------------------------------
