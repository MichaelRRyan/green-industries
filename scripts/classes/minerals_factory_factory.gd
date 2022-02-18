extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name MineralsFactoryFactory
func generate_scene(_inventory):
	if not is_able_build(_inventory):
		return null
	_inventory.change_money(-3000)
	var factory = generate_bought_scene()
	factory.set_inventory(_inventory)
	var resource_manager = Utility.get_dependency("resource_manager", null, true)
	factory.set_input_material(resource_manager.get_resource_type_by_name("minerals").id)
	factory.set_output_money_amount(130)
	return factory

func is_able_build(_inventory) -> bool:
	var purchase_amount = 3000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false

func generate_bought_scene():
	var scene = load("res://scenes/buildings/factory.tscn")
	var factory = scene.instance()
	return factory
