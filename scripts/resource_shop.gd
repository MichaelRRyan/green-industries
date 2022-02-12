extends Control

var data = null
var resource_manager = null
onready var num_wood = 0
onready var num_minerals = 0
onready var wood_amount : Label = find_node("WoodAmount")
onready var minerals_amount : Label = find_node("MineralsAmount")
const WOOD_BUY_AMOUNT = 20
const WOOD_SELL_AMOUNT = 15
const MINERALS_BUY_AMOUNT = 30
const MINERALS_SELL_AMOUNT = 25


# ------------------------------------------------------------------------------
func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_display_amounts()
	_reset()


# ------------------------------------------------------------------------------
func _ready():
	
	resource_manager = Utility.get_dependency("resource_manager", self, true)
	data = Utility.get_dependency("player_data_manager", self, true).local_player_data
	data._inventory.change_money(200)
	_display_amounts()
	print(data)


# ------------------------------------------------------------------------------
func _on_Wood_1_button_down():
	num_wood += 1
	wood_amount.text = "Wood amount: " + str(num_wood)
	

# ------------------------------------------------------------------------------
func _on_Wood_5_button_down():
	num_wood += 5
	wood_amount.text = "Wood amount: " + str(num_wood)


# ------------------------------------------------------------------------------
func _on_Wood_10_button_down():
	num_wood += 10
	wood_amount.text = "Wood amount: " + str(num_wood)


# ------------------------------------------------------------------------------
func _on_Wood_All_button_down():
	num_wood = data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))
	wood_amount.text = "Wood amount: " + str(num_wood)


# ------------------------------------------------------------------------------
func _on_Minerals_1_button_down():
	num_minerals += 1
	minerals_amount.text = "Minerals amount: " + str(num_minerals)


# ------------------------------------------------------------------------------
func _on_Minerals_5_button_down():
	num_minerals += 5
	minerals_amount.text = "Minerals amount: " + str(num_minerals)


# ------------------------------------------------------------------------------
func _on_Minerals_10_button_down():
	num_minerals += 10
	minerals_amount.text = "Minerals amount: " + str(num_minerals)


# ------------------------------------------------------------------------------
func _on_Minerals_All_button_down():
	num_minerals = data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))
	minerals_amount.text = "Minerals amount: " + str(num_minerals)


# ------------------------------------------------------------------------------
func _on_Clear_button_down():
	_reset()


# ------------------------------------------------------------------------------
func _on_Sell_button_down():
	var actual_wood_amount =\
		data._inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))
	var actual_minerals_amount =\
		data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))
	if actual_minerals_amount >= num_minerals and actual_wood_amount >= num_wood and (num_wood > 0\
	or num_minerals > 0):
		var total_cost = (num_wood * WOOD_SELL_AMOUNT) + (num_minerals * MINERALS_SELL_AMOUNT)
		data._inventory.change_money(total_cost)
		data._inventory.\
			remove_resources(resource_manager.get_resource_type_by_name("wood"), num_wood)
		data._inventory.\
			remove_resources(resource_manager.get_resource_type_by_name("minerals"), num_minerals)
		_reset()
		_display_amounts()
	else:
		print("Can't sell")


# ------------------------------------------------------------------------------
func _on_Buy_button_down():
	var total_cost = num_wood * WOOD_BUY_AMOUNT + num_minerals * MINERALS_BUY_AMOUNT
	if data._inventory.get_money() >= total_cost and (num_minerals > 0 or num_wood > 0):
		data._inventory.change_money(-total_cost)
		data._inventory.add_resources(resource_manager.get_resource_type_by_name("wood"), num_wood)
		data._inventory.add_resources(resource_manager.get_resource_type_by_name("minerals"),\
			num_minerals)
		_display_amounts()
		_reset()
	else:
		print("Can't buy")


# ------------------------------------------------------------------------------
func _display_amounts() -> void:
	print("Total Money: " + str(data._inventory.get_money()))
	print("Total Wood: " + str(data._inventory.get_quantity(\
		resource_manager.get_resource_type_by_name("wood"))))
	print("Total Minerals: " + str(\
		data._inventory.get_quantity(resource_manager.get_resource_type_by_name("minerals"))))


# ------------------------------------------------------------------------------
func _reset():
	num_wood = 0
	num_minerals = 0
	wood_amount.text = "Wood amount: " + str(num_wood)
	minerals_amount.text = "Minerals amount: " + str(num_minerals)

# ------------------------------------------------------------------------------
