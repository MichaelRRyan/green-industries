extends "res://addons/gut/test.gd"

# The test est scene.
var GameplayScene = preload("res://scenes/gameplay/gameplay.tscn")

const PLAYER_DATA_NAME : String = "PlayerData"
const HUD_NAME : String = "HUD"
const RESOURCE_MANAGER_NAME : String = "ResourceManager"
const RESOURCE_TEXTURE_NODE_NAME : String = "ResourceTexture"
const QUANTITY_LABEL_NODE_NAME : String = "QuantityLabel"

const PAUSE_BUTTON_NAME : String = "PauseButton"
const SHOP_BUTTON_NAME : String = "ShopButton"
const PAUSE_MENU_NAME : String = "PauseMenu"
const SHOP_MENU_NAME : String = "ResourceShop"
const SCORE_VISUAL_NAME : String = "ScoreVisual"

const WOOD_RESOURCE_NAME = "wood"
const MINERALS_RESOURCE_NAME = "minerals"

var _gameplay = null
var _hud = null
var _inventory : Inventory = null
var _resource_manager = null

var _wood : ResourceType
var _minerals : ResourceType


# ------------------------------------------------------------------------------
func before_all() -> void:
	# Checks the gameplay scene isn't null and then adds it as a child.
	assert_not_null(GameplayScene)
	_gameplay = GameplayScene.instance()
	add_child(_gameplay)
	
	_hud = find_node(HUD_NAME, true, false)
	assert_not_null(_hud)
	
	# Finds a child node with the player data name and ensures it's not null.
	var player_data = find_node(PLAYER_DATA_NAME, true, false)
	assert_not_null(player_data)
	
	# Gets a the player data's inventory and ensures it's not null.
	_inventory = player_data._inventory
	assert_not_null(_inventory)
	
	# Tries to find the resource manager and ensures it's not null.
	_resource_manager = find_node(RESOURCE_MANAGER_NAME, true, false)
	assert_not_null(_resource_manager)
	
	# Gets the resources.
	_wood = _resource_manager.get_resource_type_by_name(WOOD_RESOURCE_NAME)
	_minerals = _resource_manager.get_resource_type_by_name(MINERALS_RESOURCE_NAME)


# ------------------------------------------------------------------------------
func after_all():
	_gameplay.free()


# ------------------------------------------------------------------------------
func before_each() -> void:
	_inventory.clear()


# ------------------------------------------------------------------------------
func test_empty_inventory_is_displayed_empty() -> void:
	assert_eq(_hud._filled_slots.size(), 0, "UI hotbar is not displaying empty") 


# ------------------------------------------------------------------------------
func test_hud_displays_new_resources() -> void:
	# Adds some wood to the player's inventory.
	_inventory.add_resources(_wood, 5)
	
	# Checks the inventory UI contains the correct number of resource slots.
	assert_eq(_hud._filled_slots.size(), 1, 
		"HUD isn't displaying the correct number of resources")


# ------------------------------------------------------------------------------
func test_hud_displays_resources_correctly() -> void:
	# Adds some wood to the player's inventory.
	_inventory.add_resources(_wood, 5)
	
	# Checks the HUD is using the correct resource texture region.
	var resource_texture = _hud._filled_slots[_wood].get_node(RESOURCE_TEXTURE_NODE_NAME)
	assert_not_null(resource_texture.texture)
	assert_eq(resource_texture.texture.region, _wood.texture_region)
	
	# Checks the resource quantity display is correct.
	var quantity_label = _hud._filled_slots[_wood].get_node(QUANTITY_LABEL_NODE_NAME)
	assert_eq(quantity_label.text, str(_inventory.get_quantity(_wood)))


# ------------------------------------------------------------------------------
func test_hud_updates_resource_quantity() -> void:
	# Adds some wood to the player's inventory.
	_inventory.add_resources(_wood, 5)
	
	# Checks the resource quantity display is correct.
	var quantity_label = _hud._filled_slots[_wood].get_node(QUANTITY_LABEL_NODE_NAME)
	assert_eq(quantity_label.text, str(_inventory.get_quantity(_wood)))
	
	# Adds more wood to the inventory and checks the quantity label was updated.
	_inventory.add_resources(_wood, 5)
	assert_eq(quantity_label.text, str(_inventory.get_quantity(_wood)))


# ------------------------------------------------------------------------------
func test_hud_updates_added_and_removed_resources() -> void:
	# Checks the inventory UI contains no resource slots.
	assert_eq(_hud._filled_slots.size(), 0, 
		"HUD isn't displaying the correct number of resources (0)")
	
	# Adds some wood to the player's inventory and checks the UI reflect it.
	_inventory.add_resources(_wood, 5)
	assert_eq(_hud._filled_slots.size(), 1, 
		"HUD isn't displaying the correct number of resources (1)")
	
	# removes the wood from the player's inventory and checks the UI reflect it.
	var _r = _inventory.remove_resources(_wood, 5)
	assert_eq(_hud._filled_slots.size(), 0, 
		"HUD isn't displaying the correct number of resources (0)")
	
	# Adds two different resource types and checks the number of slots is correct.
	_inventory.add_resources(_wood, 5)
	_inventory.add_resources(_minerals, 10)
	assert_eq(_hud._filled_slots.size(), 2, 
		"HUD isn't displaying the correct number of resources (2)")


# ------------------------------------------------------------------------------
func test_hud_displays_money_correctly() -> void:
	# Checks the money is being displayed.
	assert_eq(_hud._money_label.text, 
		Utility.get_currency_format_string(_inventory.get_money()))
	
	# Sets the player's money and checks that the display has changed.
	_inventory.set_money(50)
	assert_eq(_hud._money_label.text, 
		Utility.get_currency_format_string(_inventory.get_money()))
	
	# Increases the player's money and checks that the display has changed.
	_inventory.change_money(50)
	assert_eq(_hud._money_label.text, 
		Utility.get_currency_format_string(_inventory.get_money()))
	
	# Decreases the player's money and checks that the display has changed.
	_inventory.change_money(-50)
	assert_eq(_hud._money_label.text, 
		Utility.get_currency_format_string(_inventory.get_money()))


# ------------------------------------------------------------------------------
func test_tool_buttons() -> void:
	# Checks the UI is displaying the correct tool at the beginning.
	var selected_tool = _hud._game_state.get_selected_tool()
	assert_true(_hud._tool_button_highlights[selected_tool].visible)
	
	# Checks that the highlighted button changes when the tool does.
	_hud._game_state.set_selected_tool(Tool.Type.BUY_LAND)
	assert_true(_hud._tool_button_highlights[Tool.Type.BUY_LAND].visible)
	
	_hud._game_state.set_selected_tool(Tool.Type.BUILD)
	assert_true(_hud._tool_button_highlights[Tool.Type.BUILD].visible)
	
	_hud._game_state.set_selected_tool(Tool.Type.DESTROY)
	assert_true(_hud._tool_button_highlights[Tool.Type.DESTROY].visible)
	
	_hud._game_state.set_selected_tool(Tool.Type.SELECT)
	assert_true(_hud._tool_button_highlights[Tool.Type.SELECT].visible)


# ------------------------------------------------------------------------------
func test_pause_button() -> void:
	# Ensures the pause button exists on the HUD and is not hidden.
	var pause_button = _hud.find_node(PAUSE_BUTTON_NAME)
	assert_not_null(pause_button)
	assert_true(pause_button.visible)
	
	# Ensures the pause menu can be found and is hidden by default.
	var pause_menu = find_node(PAUSE_MENU_NAME, true, false)
	assert_not_null(pause_menu)
	assert_false(pause_menu.visible)
	
	# Calls the pause button's pressed signal and checks that the pause menu is 
	#	now visible.
	pause_button.emit_signal("pressed")
	assert_true(pause_menu.visible)
	
	# Calls the pause button's pressed signal and checks that the pause menu is 
	#	now invisible.
	pause_button.emit_signal("pressed")
	assert_false(pause_menu.visible)
	

# ------------------------------------------------------------------------------
func test_shop_button() -> void:
	# Ensures the shop button exists on the HUD and is not hidden.
	var shop_button = _hud.find_node(SHOP_BUTTON_NAME)
	assert_not_null(shop_button)
	assert_true(shop_button.visible)
	
	# Ensures the shop menu can be found and is hidden by default.
	var shop_menu = find_node(SHOP_MENU_NAME, true, false)
	assert_not_null(shop_menu)
	assert_false(shop_menu.visible)
	
	# Calls the shop button's pressed signal and checks that the shop menu is 
	#	now visible.
	shop_button.emit_signal("pressed")
	assert_true(shop_menu.visible)
	
	# Calls the shop button's pressed signal and checks that the shop menu is 
	#	now invisible.
	shop_button.emit_signal("pressed")
	assert_false(shop_menu.visible)
	

# ------------------------------------------------------------------------------
func test_score_visualiser() -> void:
	# Ensures the score visual exists on the HUD and is not hidden.
	var score_visual = _hud.find_node(SCORE_VISUAL_NAME)
	assert_not_null(score_visual)
	assert_true(score_visual.visible)
	
	# Changes the pollution level and checks the value changes.
	var value = score_visual.value
	Pollution.tree_pollution += 50
	yield(yield_for(0.3), YIELD) # Waits for the visual to update.
	assert_ne(score_visual.value, value)


# ------------------------------------------------------------------------------
