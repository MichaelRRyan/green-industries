extends "res://addons/gut/test.gd"

# Name constants.
const WOOD_RESOURCE_NAME = "wood"
const MINERALS_RESOURCE_NAME = "minerals"
const RESOURCE_MANAGER_NAME = "ResourceManager"

var GameplayScene = preload("res://scenes/gameplay.tscn")

var _gameplay = null
var _resource_manager = null


# ------------------------------------------------------------------------------
func before_all() -> void:
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	# Tries to find the resource manager and ensures it's not null.
	_resource_manager = find_node(RESOURCE_MANAGER_NAME, true, false)
	assert_not_null(_resource_manager)


# ------------------------------------------------------------------------------
func after_all() -> void:
	_gameplay.free()


# ------------------------------------------------------------------------------
func test_wood_resource_exists() -> void:
	# Tries to get the resource by name and ensures it's not null.
	var wood = _resource_manager.get_resource_type_by_name(WOOD_RESOURCE_NAME)
	assert_not_null(wood)
	

# ------------------------------------------------------------------------------
func test_minerals_resource_exists() -> void:
	# Tries to get the resource by name and ensures it's not null.
	var minerals = _resource_manager.get_resource_type_by_name(MINERALS_RESOURCE_NAME)
	assert_not_null(minerals)
	

# ------------------------------------------------------------------------------
func test_new_resources_can_be_created() -> void:
	var id = _resource_manager.add_resource_type("paper")
	
	# Tries to get the resource by id and ensures it's not null.
	var paper = _resource_manager.get_resource_type(id)
	assert_not_null(paper)


# ------------------------------------------------------------------------------
