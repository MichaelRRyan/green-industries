extends "res://scripts/buildings/powered_building.gd"

var output_material = null

onready var powered = $Powered
onready var refinery_type = $Refinery
onready var respond_to_input = false
onready var timer = $Timer
var data = null
var resource_manager = null
var num_ingredients = 0
var ingredients = {}
var inventory = null


func set_output_material(material) -> void:
	output_material = material


func get_output() -> ResourceType:
	return output_material


func _ready():
	refinery_type.text = "wood" if output_material.name == "lumber" else "metal"
	data = Utility.get_dependency("player_data_manager", self, true).local_player_data
	resource_manager = Utility.get_dependency("resource_manager", self, true)
	
	
func _process(_delta):
	powered.text = "powered" if is_powered() else "unpowered"


func _add_resource_to_building(ingredient) -> void:
	var id = ingredient.resource_id
	var num_ingredient = inventory.get_quantity(resource_manager.get_resource_type(id))
	if num_ingredient > 0:
		if not ingredients.has(id):
			ingredients[id] = 0
		ingredients[id] += 1
		inventory.remove_resources(resource_manager.get_resource_type(id), 1)
		num_ingredient = inventory.get_quantity(resource_manager.get_resource_type(id))


func _on_Refinery_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("upgrade_factory") and respond_to_input:
		_input_ingredients()

func _input_ingredients():
	for ingredient in output_material.recipe.ingredients:
		_add_resource_to_building(ingredient)

func _on_Timer_timeout():
	respond_to_input = true

func _has_all_required_ingredients() -> bool:
	for ingredient in output_material.recipe.ingredients:
			var id = ingredient.resource_id
			if not ingredients.has(id):
				return false
			if ingredients[id] < ingredient.quantity:
				return false
	return true

func _reduce_stored_resources() -> void:
	for ingredient in output_material.recipe.ingredients:
		var id = ingredient.resource_id
		print("Amount of resource: " + \
			str(ingredients[id]))
		ingredients[id] -= ingredient.quantity
		print("Amount of resource: " +\
			str(ingredients[id]))


func _on_CreateResourceTimer_timeout():
	if is_powered() and _has_all_required_ingredients():
		_reduce_stored_resources()
		inventory.add_resources(output_material, 1)
		print("Amount of refined resource: " + str(inventory.get_quantity(output_material)))
		
func set_inventory(_inventory):
	inventory = _inventory
