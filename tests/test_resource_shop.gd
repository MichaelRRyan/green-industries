extends "res://addons/gut/test.gd"

# Name constants.
const WOOD_RESOURCE_NAME = "wood"
const MINERALS_RESOURCE_NAME = "minerals"
const RESOURCE_MANAGER_NAME = "ResourceManager"
const RESOURCE_SHOP_NAME = "ResourceShop"

const TERRAIN_NAME : String = "Terrain"
const BUILD_TOOL_NAME : String = "BuildTool"
const LUMBERJACK_NAME : String = "Lumberjack"
const PLAYER_DATA_NAME : String = "PlayerData"

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

var _gameplay = null
var _terrain = null
var _build_tool = null
var _player_data = null
var _resource_manager = null
var _inventory : Inventory = null
var _resource_shop = null

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
	
	_resource_shop = find_node(RESOURCE_SHOP_NAME, true, false)
	assert_not_null(_resource_shop)

func before_each() -> void:
	_inventory.clear()
	_inventory.set_money(100)
	_resource_shop._reset()
# ------------------------------------------------------------------------------
func after_all() -> void:
	_gameplay.free()


func test_buy_resources() -> void:
	assert_eq(_inventory._money, 100)
	_resource_shop._on_Minerals_1_button_down()
	_resource_shop._on_Buy_button_down()
	assert_eq(_inventory._money, 70)
	
func test_buy_not_enough_money() -> void:
	var minerals = _resource_manager.get_resource_type_by_name(MINERALS_RESOURCE_NAME)
	var mineral_amount = _inventory.get_quantity(minerals)
	assert_eq(_inventory._money, 100)
	_resource_shop._on_Minerals_10_button_down()
	_resource_shop._on_Buy_button_down()
	assert_eq(mineral_amount, _inventory.get_quantity(minerals))
	assert_eq(_inventory._money, 100)

func test_sell_resources() -> void:
	var wood = _resource_manager.get_resource_type_by_name(WOOD_RESOURCE_NAME)
	assert_not_null(wood)
	_inventory.add_resources(wood, 5)
	assert_eq(_inventory.get_quantity(wood), 5)
	_resource_shop._on_Wood_5_button_down()
	_resource_shop._on_Sell_button_down()
	assert_eq(_inventory.get_quantity(wood), 0)
	assert_eq(_inventory._money, 175)

func test_not_enough_resources_to_sell() -> void:
	var wood = _resource_manager.get_resource_type_by_name(WOOD_RESOURCE_NAME)
	_resource_shop._on_Wood_5_button_down()
	_resource_shop._on_Sell_button_down()
	assert_eq(_inventory.get_quantity(wood), 0)
	assert_eq(_inventory._money, 100)
