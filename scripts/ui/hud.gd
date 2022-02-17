extends Control

# Dependencies.
onready var _pause_menu = Utility.get_dependency("pause_menu", self, true)
onready var _resource_shop = Utility.get_dependency("resource_shop", self, true)
var _game_state = null
var _local_player = null

# No real max money, but we need to set a cap for the visual.
const MAX_MONEY = 40000
const MAX_POLLUTION = 100 # Percentage.

var _ui_slots = [] # A list of the ui slot nodes.
var _filled_slots = {} # ResourceType : slot/slot index

onready var _money_label = find_node("MoneyLabel")
onready var _score_visual = find_node("ScoreVisual")
onready var _tool_button_highlights = {
	Tool.Type.SELECT: find_node("SelectButton").get_node("Selected"),
	Tool.Type.BUY_LAND: find_node("BuyLandButton").get_node("Selected"),
	Tool.Type.BUILD: find_node("BuildButton").get_node("Selected"),
	Tool.Type.DESTROY: find_node("DestroyButton").get_node("Selected"),
}

# ------------------------------------------------------------------------------
func _ready():
	_game_state = Utility.get_dependency("game_state", self, true)
	
	_game_state.connect("selected_tool_changed", self, 
		"_on_game_state_selected_tool_changed")
	
	# Gets the ui resource slots.
	var left_slots = find_node("ResourceSlotsLeft")
	var right_slots = find_node("ResourceSlotsRight")
	_ui_slots.append_array(left_slots.get_children())
	_ui_slots.append_array(right_slots.get_children())
	
	# Listens to the local player's inventory.
	var player_data_manager = \
		Utility.get_dependency("player_data_manager", self, true)
	
	_local_player = player_data_manager.local_player_data

	var _r # To discard the return value without warnings.
	
	_r = _local_player._inventory.connect("money_changed", self, 
		"_on_local_player_money_changed")
	
	_r = _local_player._inventory.connect("resource_changed", self, 
		"_on_local_player_resource_changed")
	

# ------------------------------------------------------------------------------
func _set_resource(type : ResourceType, quantity : int) -> void:
	# If the resource is already in the inventory.
	if _filled_slots.has(type):
		
		# If the resource stack is not empty, sets its new quantity.
		if quantity > 0:
			_filled_slots[type].set_quantity(quantity)
			
		# Else, clears the resource from the hotbar.
		else:
			_filled_slots[type].clear()
			_filled_slots.erase(type)
			
	else:
		# Finds the first available inventory slot.
		for slot in _ui_slots:
			if slot.is_empty():
				slot.set_resource(type, quantity)
				_filled_slots[type] = slot
				break # Mission accomplished, exits.


# ------------------------------------------------------------------------------
func _on_local_player_money_changed(_money : int) -> void:
	_money_label.text = Utility.get_currency_format_string(_money)


# ------------------------------------------------------------------------------
func _on_local_player_resource_changed(resource : ResourceType, quantity : int) -> void:
	_set_resource(resource, quantity)


# ------------------------------------------------------------------------------
func _on_SelectButton_pressed():
	_game_state.set_selected_tool(Tool.Type.SELECT)


# ------------------------------------------------------------------------------
func _on_BuyLandButton_pressed():
	_game_state.set_selected_tool(Tool.Type.BUY_LAND)


# ------------------------------------------------------------------------------
func _on_BuildButton_pressed():
	_game_state.set_selected_tool(Tool.Type.BUILD)


# ------------------------------------------------------------------------------
func _on_DestroyButton_pressed():
	_game_state.set_selected_tool(Tool.Type.DESTROY)


# ------------------------------------------------------------------------------
func _on_game_state_selected_tool_changed(new_tool : int, old_tool : int) -> void:
	_tool_button_highlights[new_tool].show()
	_tool_button_highlights[old_tool].hide()


# ------------------------------------------------------------------------------
func _on_PauseButton_pressed():
	_pause_menu.toggle()


# ------------------------------------------------------------------------------
func _on_ShopButton_pressed():
	_resource_shop.toggle()


# ------------------------------------------------------------------------------
func _on_ScoreUpdateTimer_timeout():
	var pollution = _local_player.pollution_caused / 100.0 # Now between 0 and 1
	#var profit = _local_player._inventory.get_money() / MAX_MONEY
	_score_visual.value = 1 - pollution


# ------------------------------------------------------------------------------
