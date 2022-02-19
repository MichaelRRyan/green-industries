extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const PYLON_NAME : String = "Pylon"
const POWER_PLANT_NAME : String = "PowerPlant"
const FACTORY_NAME : String = "Factory"
const PLAYER_DATA_NAME : String = "PlayerData"
const RESOURCE_MANAGER_NAME = "ResourceManager"
const WOOD_FACTORY_AMOUNT = 130

# The cell in the tile map where the test will take place.
const TEST_CELL = Vector2(0, 0)
const POSIBLE_CELLS = [Vector2(0,5), Vector2(10,10), Vector2(0,6),  Vector2(6,4), Vector2(0, 7), Vector2(0,1)]

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

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
	
	yield(yield_for(0.1), YIELD)
	
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
	_resource_manager = find_node(RESOURCE_MANAGER_NAME, true, false)
	assert_not_null(_resource_manager)


# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()


# ------------------------------------------------------------------------------
func before_each() -> void:
	# Sets the tile type to empty so we can place a building.
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	for cell in POSIBLE_CELLS:
		_terrain.set_cellv(cell, Tile.Type.GRASS)


func test_factory_gives_money() -> void:
	_inventory.set_money(50000)
	_inventory.add_resources(_resource_manager.get_resource_type_by_name("wood"), 1)
	_build_tool.set_building_type(Tile.Type.POWER_PLANT)
	_build_tool.place_building(TEST_CELL)
	assert_eq(Tile.Type.POWER_PLANT, _terrain.get_cellv(TEST_CELL))
	_build_tool.set_building_type(Tile.Type.WOOD_FACTORY)
	_build_tool.place_building(POSIBLE_CELLS[4])
	assert_eq(Tile.Type.WOOD_FACTORY, _terrain.get_cellv(POSIBLE_CELLS[4]))
	_build_tool.set_building_type(Tile.Type.PYLON)
	_build_tool.place_building(POSIBLE_CELLS[0])
	assert_eq(Tile.Type.PYLON, _terrain.get_cellv(POSIBLE_CELLS[0]))
	var money = _inventory.get_money()
	yield(yield_for(0.15), YIELD)
	var factory = find_node(FACTORY_NAME, true, false)
	factory.on_click()
	var power_plant = find_node(POWER_PLANT_NAME, true, false)
	var pylon = find_node(PYLON_NAME, true, false)
	yield(yield_for(5.15), YIELD)
	assert_true(factory.is_powered())
	assert_true(pylon.is_powered())
	assert_true(power_plant.is_powered())
	assert_eq(_inventory.get_money(), money + WOOD_FACTORY_AMOUNT)
	assert_eq(_inventory.get_quantity(_resource_manager.get_resource_type_by_name("wood")), 0)
	pylon.queue_free()
	power_plant.queue_free()
	factory.queue_free()
