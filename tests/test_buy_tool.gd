extends "res://addons/gut/test.gd"

const TERRAIN_NAME : String = "Terrain"
const BUY_TOOL_NAME : String = "BuyTool"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const FACTORY_NAME : String = "Factory"
const MINE_NAME : String = "Mine"

const TEST_CELL = Vector2(5, 5)

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _buy_tool = null
var _build_tool = null

func before_all() ->void:
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	# Finds a child node with the terrain name and ensures it's not null.
	_terrain = find_node(TERRAIN_NAME, true, false)
	assert_not_null(_terrain)
	
	_build_tool = find_node(BUILD_TOOL_NAME, true, false)
	assert_not_null(_build_tool)
	
	# Finds a child node with the but tool name and ensures it's not null.
	_buy_tool = find_node(BUY_TOOL_NAME, true, false)
	assert_not_null(_buy_tool)
	
	#it was offline by default so the id was wrong 
	Network.state = Network.State.SOLO

func after_all() ->void:
	_gameplay.free()
	

func before_each() -> void:
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	
	# Sets all neighbour cells to grass.
	for neighbour in Utility.get_neighbours(TEST_CELL):
		_terrain.set_cellv(neighbour, Tile.Type.GRASS)
	
	_buy_tool._inventory.set_money(29000)
	_buy_tool.owner_dict.clear()
func test_tile_bought() ->void:
	
	
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	
	assert_false(_buy_tool.owner_dict.has(TEST_CELL))
	_buy_tool.buy_tile(TEST_CELL)
	assert_true(_buy_tool.owner_dict.has(TEST_CELL))
	
	assert_eq(_buy_tool.owner_dict[TEST_CELL].id, 1)
	

func test_right_price() ->void:
	var inventory = _buy_tool._inventory
	var tile_pos = Vector2(20,20)
	
	assert_eq(inventory.get_money(), 29000)
	_terrain.set_cellv(tile_pos, Tile.Type.GRASS) 
	_buy_tool.buy_tile(tile_pos)
	assert_eq(inventory.get_money(), 28000)
	
	tile_pos += Vector2(1,1)
	_terrain.set_cellv(tile_pos, Tile.Type.WATER) 
	_buy_tool.buy_tile(tile_pos)
	assert_eq(inventory.get_money(), 26500)
	
	tile_pos += Vector2(1,1)
	_terrain.set_cellv(tile_pos, Tile.Type.MEADOW) 
	_buy_tool.buy_tile(tile_pos)
	assert_eq(inventory.get_money(), 24500)
	
	tile_pos += Vector2(1,1)
	_terrain.set_cellv(tile_pos, Tile.Type.FOREST) 
	_buy_tool.buy_tile(tile_pos)
	assert_eq(inventory.get_money(), 21500)
	
	tile_pos += Vector2(1,1)
	_terrain.set_cellv(tile_pos, Tile.Type.STONE) 
	_buy_tool.buy_tile(tile_pos)
	assert_eq(inventory.get_money(), 18000)


func test_lumberjack_harvests_bought_wood_tiles() -> void:
	_buy_tool.buy_tile(TEST_CELL)
	
	# Places the lumberjack building.
	_build_tool.set_building_type(Tile.Type.LUMBERJACK)
	_build_tool.place_building(TEST_CELL)
	
	# Finds and modifies the lumberjack to harvest faster.
	var lumberjack = find_node(LUMBERJACK_NAME, true, false)
	lumberjack.set_seconds_per_harvest(0.1)
	
	# Gets the lumberjack's neighbours and makes sure there's 6 of them.
	var neighbours = Utility.get_neighbours(TEST_CELL)
	
	_buy_tool.buy_tile(neighbours[0])
	
	# Sets a forest tile to the neighbour location.
	_terrain.set_cellv(neighbours[0], Tile.Type.FOREST)
	_terrain.set_cellv(neighbours[1], Tile.Type.FOREST)
	
	# Waits a little longer than the harvest time.
	yield(yield_for(0.15), YIELD)
	
	# Checks damage has been done and sets the tile back to grass.
	assert_true(_terrain.damage_dict.has(neighbours[0]))
	_terrain.set_cellv(neighbours[0], Tile.Type.GRASS)
	
	yield(yield_for(0.15), YIELD)
	assert_false(_terrain.damage_dict.has(neighbours[1]))

func test_mine_harvests_bought_mineral_tiles() -> void:
	_buy_tool.buy_tile(TEST_CELL)
	
	# Places the mine building.
	_build_tool.set_building_type(Tile.Type.MINE)
	_build_tool.place_building(TEST_CELL)
	
	# Finds and modifies the mine to harvest faster.
	var mine = find_node(MINE_NAME, true, false)
	mine.set_seconds_per_harvest(0.1)
	
	# Gets the mine's neighbours and makes sure there's 6 of them.
	var neighbours = Utility.get_neighbours(TEST_CELL)
	
	_buy_tool.buy_tile(neighbours[0])
	# Sets a stone tile to the neighbour location.
	_terrain.set_cellv(neighbours[0], Tile.Type.STONE)
	_terrain.set_cellv(neighbours[1], Tile.Type.STONE)
	
	# Waits a little longer than the harvest time.
	yield(yield_for(0.15), YIELD)
	
	# Checks damage has been done and sets the tile back to grass.
	assert_true(_terrain.damage_dict.has(neighbours[0]))
	_terrain.set_cellv(neighbours[0], Tile.Type.GRASS)
	
	yield(yield_for(0.15), YIELD)
	assert_false(_terrain.damage_dict.has(neighbours[1]))


func test_buy_tile_when_placing_building() ->void:
	_buy_tool.owner_dict.clear()
	_terrain.set_cellv(TEST_CELL, Tile.Type.GRASS)
	
	_build_tool.set_building_type(Tile.Type.FACTORY)
	
	_build_tool.place_building(TEST_CELL)
		
	assert_eq(_buy_tool.owner_dict[TEST_CELL].id, 1)
	
	
	# Places the building and check that it has been placed.
	assert_eq(Tile.Type.FACTORY, _terrain.get_cellv(TEST_CELL))
	
	# Checks if a mine instance can be found.
	var factory = find_node(FACTORY_NAME, true, false)
	assert_not_null(factory)
