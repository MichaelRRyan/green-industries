extends "res://addons/gut/test.gd"

const PLAYER_DATA : String = "PlayerData"
const DIALOG_NAME : String = "AcceptDialog"

var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

var _gameplay = null
var inventory : Inventory = null
var dialog : AcceptDialog = null
var resource_manager = null

func before_all() ->void:
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	yield(yield_for(0.1), YIELD)
	
	inventory = find_node(PLAYER_DATA, true, false)._inventory
	assert_not_null(inventory)
	
	dialog = find_node(DIALOG_NAME, true, false)
	assert_not_null(dialog)
	resource_manager = Utility.get_dependency("resource_manager", self, true)

func after_all() ->void:
	_gameplay.free()

func before_each() ->void:
	dialog.hide()

func test_low_and_no_money() ->void:
	inventory.set_money(200)
	assert_true(dialog.visible)
	
	dialog.hide()
	
	inventory.set_money(0)
	assert_true(dialog.visible)

func test_no_resources() ->void:
	inventory.add_resources(resource_manager.get_resource_type_by_name("wood"), 1)
	var _r = inventory.remove_resources(resource_manager.get_resource_type_by_name("wood"), 1)
	assert_true(dialog.visible)
	
	dialog.hide()
	
	inventory.add_resources(resource_manager.get_resource_type_by_name("minerals"), 1)
	_r = inventory.remove_resources(resource_manager.get_resource_type_by_name("minerals"), 1)
	assert_true(dialog.visible)
	
	dialog.hide()
	
	inventory.add_resources(resource_manager.get_resource_type_by_name("lumber"), 1)
	_r = inventory.remove_resources(resource_manager.get_resource_type_by_name("lumber"), 1)
	assert_true(dialog.visible)
	
	dialog.hide()
	
	inventory.add_resources(resource_manager.get_resource_type_by_name("minerals"), 1)
	_r = inventory.remove_resources(resource_manager.get_resource_type_by_name("minerals"), 1)
	assert_true(dialog.visible)
