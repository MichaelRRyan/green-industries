extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name MineralsRefineryFactory
func generate_scene(_inventory):
	resource_manager = Utility.get_dependency("resource_manager", null, true)
	var purchase_amount = 3000
	var wood_amount = _inventory.get_quantity(resource_manager.get_resource_type_by_name("wood"))
	if not is_able_build(_inventory):
		return null
	print("Current Money: " + str(_inventory.get_money()))
	_inventory.change_money(-purchase_amount)
	_inventory.remove_resources(resource_manager.get_resource_type_by_name("wood"), 5)
	print("Current Money: " + str(_inventory.get_money()))
	return generate_bought_scene()

func is_able_build(_inventory) -> bool:
	var purchase_amount = 3000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false

func generate_bought_scene():
	var scene = load("res://scenes/buildings/refinery.tscn")
	var refinery = scene.instance()
	var resource_manager = Utility.get_dependency("resource_manager")
	var output_material = resource_manager.get_resource_type_by_name("metal")
	refinery.set_output_material(output_material)
	return refinery
