extends "res://addons/gut/test.gd"

# Name constants.
const TERRAIN_NAME : String = "Terrain"
const POLLUTION_MANAGER_NAME : String = "PollutionManager"
const BUILD_TOOL_NAME : String = "BuildTool"

const AI_CONTROLLER_GROUP : String = "ai_controller"

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _pollution_manager = null
var _build_tool = null

# ------------------------------------------------------------------------------
func before_each() -> void:
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	# Finds a child node with the terrain name and ensures it's not null.
	_terrain = find_node(TERRAIN_NAME, true, false)
	assert_not_null(_terrain)
	
	# Finds a child node with the pollution manager name and ensures it's not null.
	_pollution_manager = find_node(POLLUTION_MANAGER_NAME, true, false)
	assert_not_null(_pollution_manager)
	
	# Finds a child node with the build tool name and ensures it's not null.
	_build_tool = find_node(BUILD_TOOL_NAME, true, false)
	assert_not_null(_build_tool)
	


# ------------------------------------------------------------------------------
func after_each():
	_gameplay.free()


# ------------------------------------------------------------------------------
func test_pollution_decreases_over_time() -> void:
	
	# Disables the AI so they don't interfere.
	var ais = get_tree().get_nodes_in_group(AI_CONTROLLER_GROUP)
	for ai in ais:
		ai._set_inactive()
	
	var yield_time = 2
	var start_pollution = 50.0
	
	# Sets the start pollution and waits for the specified time.
	_pollution_manager._pollution_percent = start_pollution
	yield(yield_for(yield_time), YIELD)
	
	# Gets the end pollution and ensures it's less than the start pollution.
	var end_pollution = _pollution_manager._pollution_percent
	assert_lt(end_pollution, start_pollution)
	
	var decrement_rate = (start_pollution - end_pollution) / yield_time
	
	# Removes 50 trees.
	_remove_trees(50)
	
	# Sets the start pollution and waits for the specified time.
	_pollution_manager._pollution_percent = start_pollution
	yield(yield_for(yield_time), YIELD)
	
	# Gets the end pollution and ensures it's less than the start pollution.
	var new_end_pollution = _pollution_manager._pollution_percent
	assert_lt(new_end_pollution, start_pollution)
	
	# Works out the new decrement rate and checks that it's less than the previous.
	var new_decrement_rate = (start_pollution - new_end_pollution) / yield_time
	assert_lt(new_decrement_rate, decrement_rate)
	
	
# ------------------------------------------------------------------------------
func _remove_trees(number : int) -> void:
	# Loops through all tiles and and gets the cell.
	for x in _terrain.WIDTH:	
		for y in _terrain.HEIGHT:
			var cell = Vector2(x, y)
			
			# If the tile is a forest, loop through all its health and damages it.
			if Tile.Type.FOREST == _terrain.get_cellv(cell):
				for _i in _pollution_manager._TREES_PER_TILE:
					_terrain._damage_cell(cell)
				
				# Decrement the number of trees to remove and checks if complete.
				number -= 1
				if number == 0:
					return


# ------------------------------------------------------------------------------
func test_power_buildings_cause_pollution() -> void:
	# Sets the total trees to zero so no pollution decreases.
	_pollution_manager._total_trees = 0
	
	# Picks a test tile and sets it to grass.
	var test_tile = Vector2(0, 0)
	_terrain.set_cellv(test_tile, Tile.Type.GRASS)
	
	# Places a power plant on the test tile.
	_build_tool.set_building_type(Tile.Type.POWER_PLANT)
	_build_tool.place_building(test_tile)
	
	# Waits and checks the pollution amount has increased.
	var pollution = _pollution_manager._pollution_percent
	yield(yield_for(0.5), YIELD)
	assert_gt(_pollution_manager._pollution_percent, pollution)
	
	# Waits again and checks the pollution amount has continued to increased.
	pollution = _pollution_manager._pollution_percent
	yield(yield_for(0.5), YIELD)
	assert_gt(_pollution_manager._pollution_percent, pollution)
	

# ------------------------------------------------------------------------------
func test_harvesting_stone_increases_pollution() -> void:
	# Gets the correct pollution level.
	var pollution = _pollution_manager._pollution_percent
	
	# Picks a test tile and sets it to stone.
	var test_tile = Vector2(0, 0)
	_terrain.set_cellv(test_tile, Tile.Type.STONE)
	
	# Damages the test tile and checks the pollution has increased.
	_terrain._damage_cell(test_tile)
	assert_gt(_pollution_manager._pollution_percent, pollution)


# ------------------------------------------------------------------------------
func test_tiles_become_polluted():
	
	# Increases the pollution amount and waits for the polluted signal. 
	_pollution_manager._pollute_by_amount(80)
	yield(yield_to(_pollution_manager, "cell_polluted", 30), YIELD)
	
	# Assert that the cell polluted signal was emitted.
	assert_signal_emitted(_pollution_manager, "cell_polluted")
	
	# Asserts that the last polluted cell is actually a polluted type.
	var type = _terrain.get_cellv(_pollution_manager._last_polluted)
	assert_true(is_a_polluted_tile(type))
	

# ------------------------------------------------------------------------------
func is_a_polluted_tile(tile_type : int) -> bool:
	match (tile_type):
		Tile.Type.DIRT: return true
		Tile.Type.PATCHED_GRASS: return true
		Tile.Type.CRACKED_STONE: return true
		Tile.Type.DEAD_FOREST: return true
		Tile.Type.MURKY_WATER: return true
	return false
	

# ------------------------------------------------------------------------------
