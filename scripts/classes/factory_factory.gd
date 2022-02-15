extends "res://scripts/classes/abstract_factory_pattern.gd"

class_name FactoryFactory
func generate_scene(_inventory):
	if not is_able_build(_inventory):
		return null
	_inventory.change_money(-3000)
	return generate_bought_scene()

func is_able_build(_inventory) -> bool:
	var purchase_amount = 3000
	if _inventory.get_money() >= purchase_amount:
		return true
	return false

func generate_bought_scene():
	var scene = load("res://scenes/factory.tscn")
	var factory = scene.instance()
	return factory
