extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const MINE_NAME : String = "Mine"
const BULLDOZER_TOOL_NAME : String = "BullDozerTool"
const BUY_TOOL_NAME : String = "BuyTool"
const PYLON_NAME : String = "Pylon"
const PLAYER_DATA_NAME : String = "PlayerData"
const RESOURCE_MANAGER_NAME = "ResourceManager"
const POWER_PLANT_NAME : String = "PowerPlant"
# The cell in the tile map where the test will take place.
const TEST_CELL = Vector2(0, 0)
const NOT_BOUGHT_TILE = Vector2(70, 70)
const POSIBLE_CELLS = [Vector2(0,5), Vector2(10,10), Vector2(0,6),  Vector2(6,4), Vector2(0, 7), Vector2(0,1)]
var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _build_tool = null
var _buy_tool = null
var _bulldozer_tool = null
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
	
	_bulldozer_tool = find_node(BULLDOZER_TOOL_NAME, true, false)
	assert_not_null(_bulldozer_tool)
	
	# Finds a child node with the but tool name and ensures it's not null.
	_buy_tool = find_node(BUY_TOOL_NAME, true, false)
	assert_not_null(_buy_tool)
	
		# Finds a child node with the player data name and ensures it's not null.
	_player_data = find_node(PLAYER_DATA_NAME, true, false)
	assert_not_null(_player_data)
	
	# Gets a the player data's inventory and ensures it's not null.
	_inventory = _player_data._inventory
	assert_not_null(_inventory)


# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()


# ------------------------------------------------------------------------------
func before_each() -> void:
	# Sets the tile type to empty so we can place a building.
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	for cell in POSIBLE_CELLS:
		_terrain.set_cellv(cell, Tile.Type.GRASS)


# ------------------------------------------------------------------------------
func test_lumberjack_can_be_removed() -> void:
	# Selects the lumberjack building.
	_build_tool.set_building_type(Tile.Type.LUMBERJACK)
	
	# Places the building and check that it has been placed.
	_build_tool.place_building(TEST_CELL)
	assert_eq(Tile.Type.LUMBERJACK, _terrain.get_cellv(TEST_CELL))
	
	# Checks if a lumberjack instance can be found.
	var lumberjack = find_node(LUMBERJACK_NAME, true, false)
	assert_not_null(lumberjack)
	_bulldozer_tool.bulldose_tile(TEST_CELL)
	assert_eq(Tile.Type.DIRT, _terrain.get_cellv(TEST_CELL))
	yield(yield_for(0.2), YIELD)
	lumberjack = find_node(LUMBERJACK_NAME, true, false)
	assert_null(lumberjack)
	

func test_resource_can_be_removed() -> void:
	_terrain.set_cellv(TEST_CELL, Tile.Type.FOREST)
	_buy_tool.buy_tile(TEST_CELL)
	assert_true(_buy_tool.owner_dict.has(TEST_CELL))
	assert_eq(_buy_tool.owner_dict[TEST_CELL].id, 1)
	_bulldozer_tool.bulldose_tile(TEST_CELL)
	assert_eq(Tile.Type.GRASS, _terrain.get_cellv(TEST_CELL))


func test_not_bought_tile_cannot_be_removed() -> void:
	_terrain.set_cellv(NOT_BOUGHT_TILE, Tile.Type.FOREST)
	assert_false(_buy_tool.owner_dict.has(NOT_BOUGHT_TILE))
	_bulldozer_tool.bulldose_tile(NOT_BOUGHT_TILE)
	assert_eq(Tile.Type.FOREST, _terrain.get_cellv(NOT_BOUGHT_TILE))
	
	
func test_power_removed_after_bulldozed() -> void:
	_inventory.set_money(70000)
	_build_tool.set_building_type(Tile.Type.POWER_PLANT)
	_build_tool.place_building(TEST_CELL)
	assert_eq(Tile.Type.POWER_PLANT, _terrain.get_cellv(TEST_CELL))
	_build_tool.set_building_type(Tile.Type.PYLON)
	_build_tool.place_building(POSIBLE_CELLS[0])
	_build_tool.place_building(POSIBLE_CELLS[4])
	assert_eq(Tile.Type.PYLON, _terrain.get_cellv(POSIBLE_CELLS[0]))
	assert_eq(Tile.Type.PYLON, _terrain.get_cellv(POSIBLE_CELLS[4]))
	yield(yield_for(0.15), YIELD)
	var pylon = find_node(PYLON_NAME, true, false)
	var power_plant = find_node(POWER_PLANT_NAME, true, false)
	var pylons = get_tree().get_nodes_in_group("pylons")
	assert_true(pylon.is_powered())
	assert_true(power_plant.is_powered())
	for py in pylons:
		assert_true(py.is_powered())
	_bulldozer_tool.bulldose_tile(TEST_CELL)
	assert_eq(Tile.Type.DIRT, _terrain.get_cellv(TEST_CELL))
	yield(yield_for(0.2), YIELD)
	pylon = find_node(PYLON_NAME, true, false)
	power_plant = find_node(POWER_PLANT_NAME, true, false)
	pylons = get_tree().get_nodes_in_group("pylons")
	assert_false(pylon.is_powered())
	assert_null(power_plant)
	for py in pylons:
		assert_false(py.is_powered())
	pylon.queue_free()
	for py in pylons:
		py.queue_free()
